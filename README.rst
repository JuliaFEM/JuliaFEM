
.. image:: https://raw.githubusercontent.com/JuliaFEM/JuliaFEM.jl/master/docs/logo/JuliaFEMLogo_256x256.png
  :target: https://github.com/JuliaFEM/JuliaFEM.jl

========
JuliaFEM
========

The JuliaFEM project develops open-source software for reliable, scalable, distributed Finite Element Method.

.. image:: https://img.shields.io/github/license/JuliaFEM/Juliafem.jl.svg
  :target: https://github.com/JuliaFEM/JuliaFEM.jl/blob/master/LICENSE.md

.. image:: https://badges.gitter.im/Join%20Chat.svg
  :target: https://gitter.im/JuliaFEM/JuliaFEM?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge

.. image:: https://travis-ci.org/JuliaFEM/JuliaFEM.jl.svg?branch=master
  :target: https://travis-ci.org/JuliaFEM/JuliaFEM.jl

.. image:: https://coveralls.io/repos/JuliaFEM/JuliaFEM.jl/badge.svg?branch=master
  :target: https://coveralls.io/r/JuliaFEM/JuliaFEM.jl?branch=master

.. image:: http://juliafem.org/_static/notebooks-status.svg?ts=1
  :target: http://juliafem.org/tutorials/index.html

.. image:: http://juliafem.org/_static/doctests-status.svg?ts=1

.. image:: http://juliafem.org/_static/unittests-status.svg?ts=1

.. image:: http://juliafem.org/_static/lint-status.svg?ts=1
  :target: http://juliafem.org/quality/index.html#lint-report

.. image:: https://img.shields.io/github/issues/JuliaFEM/JuliaFEM.jl.svg
  :target: https://github.com/JuliaFEM/JuliaFEM.jl/issues

Documentation: http://www.juliaFEM.org

GitHub repository: https://github.com/JuliaFEM/JuliaFEM.jl

IRC: #juliafem @ FreeNode, https://webchat.freenode.net/


The JuliaFEM software library is a framework that allows for the distributed processing of large Finite Element Models across clusters of computers using simple programming models. It is designed to scale up from single servers to thousands of machines, each offering local computation and storage. The basic design principle is: everything is nonlinear. All physics models are nonlinear from which the linearization are made as a special cases. 

JuliaFEM current status: project planning

Initial road map for JuliaFEM:

+---------+-----------------------------+-----------------+
| version | number of degree of freedom | number of cores |
+=========+=============================+=================+
|   0.1.0 |                   1 000 000 |              10 |
+---------+-----------------------------+-----------------+
|   0.2.0 |                  10 000 000 |             100 |
+---------+-----------------------------+-----------------+
|   1.0.0 |                 100 000 000 |           1 000 |
+---------+-----------------------------+-----------------+
|   2.0.0 |               1 000 000 000 |          10 000 |
+---------+-----------------------------+-----------------+
|   3.0.0 |              10 000 000 000 |         100 000 |
+---------+-----------------------------+-----------------+

We strongly believe in the test driven development as well as building on top of previous work. Thus all the new code in this project should be 100% tested. Also other people have wisdom in style as well:

`The Zen of Python <https://www.python.org/dev/peps/pep-0020/>`_

| Beautiful is better than ugly.
| Explicit is better than implicit.
| Simple is better than complex.
| Complex is better than complicated.
| Flat is better than nested.
| Sparse is better than dense.
| Readability counts.
| Errors should never pass silently.
|

Contributing
------------

Interested in participating? Please start by reading `CONTRIBUTING.rst <https://github.com/JuliaFEM/JuliaFEM/blob/master/CONTRIBUTING.rst>`_.

Contributors: see `contributors <https://github.com/JuliaFEM/JuliaFEM/blob/master/contributors>`_
