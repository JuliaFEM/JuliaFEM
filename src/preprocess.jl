# This file is a part of JuliaFEM.
# License is MIT: see https://github.com/JuliaFEM/JuliaFEM.jl/blob/master/LICENSE.md

#=
- read meshes from different formats
- reorder connectivity, create element sets, node sets, ...
- create partitions for parallel runs
- renumber elements / nodes
- maybe precheck for bad elements
- check surface normal direction in boundary elements
- orientation of 2d elements
- etc only topology related stuff
=#

import Base: copy

using JuliaFEM

type Mesh
    nodes :: Dict{Int, Vector{Float64}}
    node_sets :: Dict{Symbol, Set{Int}}
    elements :: Dict{Int, Vector{Int}}
    element_types :: Dict{Int, Symbol}
    element_codes :: Dict{Int, Symbol}
    element_sets :: Dict{Symbol, Set{Int}}
    surface_sets :: Dict{Symbol, Vector{Tuple{Int, Symbol}}}
    surface_types :: Dict{Symbol, Symbol}
end

function Mesh()
    return Mesh(Dict(), Dict(), Dict(), Dict(), Dict(), Dict(), Dict(), Dict())
end

function add_node!(mesh::Mesh, nid::Int, ncoords::Vector{Float64})
    mesh.nodes[nid] = ncoords
end

function add_nodes!(mesh::Mesh, nodes::Dict{Int, Vector{Float64}})
    for (nid, ncoords) in nodes
        add_node!(mesh, nid, ncoords)
    end
end

function add_node_to_node_set!(mesh::Mesh, set_name, nids...)
    if !haskey(mesh.node_sets, set_name)
        mesh.node_sets[set_name] = Set{Int}()
    end
    push!(mesh.node_sets[set_name], nids...)
    return
end

""" Create a new node set from nodes in element set. """
function create_node_set_from_element_set!(mesh::Mesh, set_names::String...)
    for set_name in set_names
        set_name = Symbol(set_name)
        info("Creating node set $set_name from element set")
        node_ids = Set{Int}()
        for elid in mesh.element_sets[set_name]
            push!(node_ids, mesh.elements[elid]...)
        end
        mesh.node_sets[set_name] = node_ids
    end
    return
end

function add_element!(mesh::Mesh, elid::Int, eltype::Symbol, connectivity::Vector{Int})
    mesh.elements[elid] = connectivity
    mesh.element_types[elid] = eltype
end

function add_elements!(mesh::Mesh, elements::Dict{Int, Tuple{Symbol, Vector{Int}}})
    for (elid, (eltype, elcon)) in elements
        add_element!(mesh, elid, eltype, elcon)
    end
end

function add_element_to_element_set!(mesh::Mesh, set_name, elids...)
    if !haskey(mesh.element_sets, set_name)
        mesh.element_sets[set_name] = Set{Int}()
    end
    push!(mesh.element_sets[set_name], elids...)
end

function copy(mesh::Mesh)
    mesh2 = Mesh()
    mesh2.nodes = copy(mesh.nodes)
    mesh2.node_sets = copy(mesh.node_sets)
    mesh2.elements = copy(mesh.elements)
    mesh2.element_types = copy(mesh.element_types)
    mesh2.element_sets = copy(mesh.element_sets)
    return mesh2
end

function filter_by_element_id(mesh::Mesh, element_ids::Vector{Int})
    mesh2 = copy(mesh)
    mesh2.elements = Dict()
    for elid in element_ids
        if haskey(mesh.elements, elid)
            mesh2.elements[elid] = mesh.elements[elid]
        end
    end
    return mesh2
end

function filter_by_element_set(mesh::Mesh, set_name)
    filter_by_element_id(mesh::Mesh, collect(mesh.element_sets[set_name]))
end

function create_element(mesh::Mesh, id::Int)
    connectivity = mesh.elements[id]
    element_type = getfield(JuliaFEM, mesh.element_types[id])
    element = Element(element_type, connectivity)
    element.id = id
    update!(element, "geometry", mesh.nodes)
    return element
end

function create_elements(mesh::Mesh; element_type=nothing)
    element_ids = collect(keys(mesh.elements))
    if element_type != nothing
        filter!(id -> mesh.element_types[id] == element_type, element_ids)
    end
    elements = [create_element(mesh, id) for id in element_ids]
    return elements
end

function create_elements(mesh::Mesh, element_sets::Symbol...; element_type=nothing)
    if isempty(element_sets)
        element_ids = collect(keys(mesh.elements))
    else
        element_ids = Set{Int}()
        for set_name in element_sets
            element_ids = union(element_ids, mesh.element_sets[set_name])
        end
    end

    if element_type != nothing
        filter!(id -> mesh.element_types[id] == element_type, element_ids)
    end

    elements = [create_element(mesh, id) for id in element_ids]
    return elements
end

function create_elements(mesh::Mesh, element_sets::AbstractString...; element_type=nothing)
    element_sets = map(parse, element_sets)
    return create_elements(mesh, element_sets...; element_type=element_type)
end


""" find npts nearest nodes from mesh and return id numbers as list. """
function find_nearest_nodes(mesh::Mesh, coords::Vector{Float64}, npts::Int=1; node_set=nothing)
    dist = Dict{Int, Float64}()
    for (nid, c) in mesh.nodes
        if node_set != nothing && !(nid in mesh.node_sets[Symbol(node_set)])
            continue
        end
        dist[nid] = norm(coords-c)
    end
    s = sort(collect(dist), by=x->x[2])
    nd = s[1:npts] # [(id1, dist1), (id2, dist2), ..., (id_npts, dist_npts)]
    node_ids = [n[1] for n in nd]
    if length(node_ids) == 1
        return first(node_ids)
    end
    return node_ids
end

"""
Apply new node ordering to elements. In JuliaFEM same node ordering is used
than in ABAQUS and if mesh is parsed from FEM format with other node ordering
this can be used to reorder nodes.

Parameters
----------
mapping :: Dict{Symbol, Vector{Int}}
    e.g. :Tet10, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

"""
function reorder_element_connectivity!(mesh::Mesh, mapping::Dict{Symbol, Vector{Int}})
    for (elid, eltype) in mesh.element_types
        haskey(mapping, eltype) || continue
        new_order = mapping[eltype]
        element_connectivity = mesh.elements[elid]
        new_element_connectivity = element_connectivity[new_order]
        mesh.elements[elid] = new_element_connectivity
    end
end

function JuliaFEM.Problem{P<:FieldProblem}(mesh::Mesh, ::Type{P}, name::AbstractString, dimension::Int)
    problem = Problem(P, name, dimension)
    problem.elements = create_elements(mesh, name)
    return problem
end

function JuliaFEM.Problem{P<:BoundaryProblem}(mesh::Mesh, ::Type{P}, name, dimension, parent_field_name)
    problem = Problem(P, name, dimension, parent_field_name)
    problem.elements = create_elements(mesh, name)
    return problem
end
