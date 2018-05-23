# Provenance Annotation and Analysis to Support Process Re-Computation

This is a public repository to provide the supplemental material for IPAW 2018 paper: _"Provenance Annotation and Analysis to Support Process Re-Computation"_

If you use any material of this repository, we would appreciate citations to:

> Cała J., Missier P. (2018) Provenance Annotation and Analysis to Support Process Re-Computation. In: XXX (eds) _Provenance and Annotation of Data and Processes. IPAW 2018_. Lecture Notes in Computer Science, vol. NNNN. Springer.

Bibtex entry (to be updated):

    @inproceedings{ipaw2018_recomp,
      author={Jacek Ca\l{}a and Paolo Missier},
      title={Provenance Annotation and Analysis to Support Process Re-Computation},
      booktitle={},
      year={2018},
      pages={}
    }

## Introduction

The repository includes the Prolog code to generate the re-computation front for the given set of documents/entities, as presented in the paper. The set of documents {may/may not} represent the change front but, importantly, it refers to the new versions of the documents.

At the moment the repository includes two sets of simple tests to show the code in action. Enjoy!

If anything is unclear or you spot a bug, please submit an issue.

## Running Tests

To run the tests you need SWI-Prolog (tested on version 7.6.4) from: http://www.swi-prolog.org.
Then, load at least one of the test files provided (see the header in test/test_front_*) and run tests.
