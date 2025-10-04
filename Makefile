#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

.PHONY: all security lint format documentation validate init commitlint

default: all

all: 
	$(MAKE) init
	$(MAKE) validate
	$(MAKE) lint
	$(MAKE) security
	$(MAKE) format
	$(MAKE) documentation

documentation: 
	@echo "--> Generating documentation"
	@terraform-docs .
	$(MAKE) documentation-examples 

documentation-examples:
	@echo "--> Generating documentation examples"
	@find . -type d -path '*/examples/*' -not -path '*.terraform*' 2>/dev/null | while read -r dir; do \
		echo "--> Generating documentation for $$dir"; \
		terraform-docs $$dir; \
	done;

init: 
	@echo "--> Running terraform init"
	@terraform init -backend=false

security: init
	@echo "--> Running Security checks"
	trivy config  --format table --exit-code 1 --severity CRITICAL,HIGH --ignorefile .trivyignore .
	$(MAKE) security-examples

security-examples:
	@echo "--> Running Security checks on examples"
	@find . -type d -path '*/examples/*' -not -path '*.terraform*' 2>/dev/null | while read -r dir; do \
		echo "--> Validating $$dir"; \
	  terraform init -backend=false; \
		trivy config  --format table --exit-code  1 --severity  CRITICAL,HIGH --ignorefile .trivyignore $$dir; \
	done;

commitlint:
	@echo "--> Running commitlint against the main branch"
	@command -v commitlint >/dev/null 2>&1 || { echo "commitlint is not installed. Please install it by running 'npm install -g commitlint'"; exit 1; }
	@git log --pretty=format:"%s" origin/main..HEAD | commitlint --from=origin/main

lint-examples:
	@echo "--> Running tflint on examples"
	@find . -type d -path '*/examples/*' -not -path '*.terraform*' 2>/dev/null | while read -r dir; do \
		echo "--> Linting $$dir"; \
		tflint --chdir=$$dir --init; \
		tflint --chdir=$$dir -f compact; \
	done; 

lint:
	@echo "--> Running tflint"
	@tflint --init 
	@tflint -f compact

format: 
	@echo "--> Running terraform fmt"
	@terraform fmt -recursive -write=true

validate-examples:
	@echo "--> Running terraform validate on examples"
	@find . -type d -path '*/examples/*' -not -path '*.terraform*' 2>/dev/null | while read -r dir; do \
		echo "--> Validating $$dir"; \
		terraform -chdir=$$dir init -backend=false; \
		terraform -chdir=$$dir validate; \
	done; 

validate:
	@echo "--> Running terraform validate"
	@terraform init -backend=false
	@terraform validate
	$(MAKE) lint 
	$(MAKE) commitlint
	$(MAKE) format
	$(MAKE) security
	$(MAKE) validate-examples
	$(MAKE) lint-examples
	$(MAKE) security-examples

clean:
	@echo "--> Cleaning up"
	@find . -type d -name ".terraform" 2>/dev/null | while read -r dir; do \
		echo "--> Removing $$dir"; \
		rm -rf $$dir; \
	done
