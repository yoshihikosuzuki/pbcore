.PHONY: clean doc doc-clean tests check test install build bdist gh-pages

build:
	python setup.py build

bdist:
	python setup.py build --executable="/usr/bin/env python"
	python setup.py bdist --formats=egg

install:
	@which pip > /dev/null
	@pip freeze|grep 'pbcore=='>/dev/null \
      && pip uninstall -y pbcore \
      || echo -n ''
	@pip install ./

pylint:
	pylint --errors-only pbcore/

clean: doc-clean
	rm -rf build/;\
	find . -name "*.egg-info" | xargs rm -rf;\
	rm -rf dist/;\
	find . -name "*.pyc" | xargs rm -f;
	rm -f nosetests.xml

doc:
	sphinx-apidoc -o doc/ pbcore/ && cd doc/ && make html
doc-clean:
	cd doc && rm -rf _templates _static _build searchindex.js objects.inv

doctest:
	cd doc && make doctest

unit-test:
	nosetests --with-coverage --cover-xml-file=coverage.xml --cover-package=pbcore --cover-xml --with-xunit -v tests
	sed -i -e 's@filename="@filename="./@g' coverage.xml

test: doctest unit-test

tests: test
check: test

GH_PAGES_SOURCES = pbcore doc

gh-pages:
	git checkout gh-pages
	rm -rf _static _sources *.js *.html *.inv
	git checkout master $(GH_PAGES_SOURCES)
	cd doc && make html
	mv -fv doc/_build/html/* .
	rm -rf $(GH_PAGES_SOURCES)
	git add --all && git commit -m "Automatic update of gh-pages branch" && git checkout master

pip-install:
	@which pip > /dev/null
	@pip freeze|grep 'pbcore=='>/dev/null \
      && pip uninstall -y pbcore \
      || echo -n ''
	@pip install --no-index ./


publish-to-pypi:
	@echo "I'm not going to do this for you, but you can do it by:"
	@echo "    % python setup.py sdist upload -r pypi"


xsd-codegen:
	rm -f pbcore/io/dataset/pyxb/DataSetXsd.py
	./bin/updateXSDs.py ../xsd-datamodels/PacBioDatasets.xsd pbcore/io/dataset/pyxb/
