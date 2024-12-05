# DMP OPIDoR

[![Actions Status](https://github.com/DMPRoadmap/roadmap/workflows/Brakeman/badge.svg)](https://github.com/DMPRoadmap/roadmap/actions)
[![Actions Status](https://github.com/DMPRoadmap/roadmap/workflows/Rubocop/badge.svg)](https://github.com/DMPRoadmap/roadmap/actions)
[![Actions Status](https://github.com/DMPRoadmap/roadmap/workflows/ESLint/badge.svg)](https://github.com/DMPRoadmap/roadmap/actions)
[![Actions Status](https://github.com/DMPRoadmap/roadmap/workflows/Tests%20-%20PostgreSQL/badge.svg)](https://github.com/DMPRoadmap/roadmap/actions)

DMP Roadmap is a Data Management Planning tool. Management and development of DMP Roadmap is jointly provided by the Digital Curation Centre (DCC), http://www.dcc.ac.uk/, and the University of California Curation Center (UC3), http://www.cdlib.org/services/uc3/.

### Requirements

- Ruby 3.2.x
- Rails 7.1.x
- NodeJS LTS
- PostgreSQL 12.x

Click here for the latest [releases](https://github.com/DMPRoadmap/roadmap/releases/).

#### Pre-requisites
Roadmap is a Ruby on Rails application and you will need to have:
- Ruby >= 3.3
- Rails = 7.2
- PostgreSQL

Further detail on how to install Ruby on Rails applications are available from the Ruby on Rails site: http://rubyonrails.org.

L'application se lance par défaut en mode développement.

## Developpment

#### Installation
See the [Installation Guide](https://github.com/DMPRoadmap/roadmap/wiki/Installation) on the Wiki.

#### Docker

#### Requirements
- [Docker](https://www.docker.com/)
- [Docker compose](https://docs.docker.com/compose/install/)

#### Installation

```bash
# init submodule
git clone https://github.com/OPIDoR/dmp_opidor_react.git app/javascript/dmp_opidor_react

```

##### Directus

Default credentials: ``admin@example.com`` / ``changeme``

```bash
# Run postgres
docker compose up -d postgres

# Create directus database
docker compose exec -it postgres sh -c "psql -U ${DB_USERNAME:-postgres} -c 'create database ${DIRECTUS_DATABASE:-directus};'"

# Copy database dump file in postgres container
docker compose cp ./directus/dump.sql postgres:/directus.sql

# Apply dump in database
docker compose exec -it postgres sh -c "psql -U ${DB_USERNAME:-postgres} ${DIRECTUS_DATABASE:-directus} < directus.sql"
```

###### Backup

```bash
# Dump directus database
docker compose exec -it postgres sh -c "pg_dump -U ${DB_USERNAME:-postgres} ${DIRECTUS_DATABASE:-directus}" > directus/dump.sql

# Drop database
docker compose exec -it postgres sh -c "psql -U ${DB_USERNAME:-postgres} -c 'drop database ${DIRECTUS_DATABASE:-directus};'"

# Repeat the steps for creating and adding the Directus database (see above)
```

##### Development mode

```bash
# build image
docker compose -f docker-compose.yml -f docker-compose-dev.yml build dmpopidor

# Configure database connection for postgres 
docker compose -f docker-compose.yml -f docker-compose-dev.yml run --rm dmpopidor sh -c 'ruby bin/docker postgres'

# Setup database
docker compose -f docker-compose.yml -f docker-compose-dev.yml run --rm dmpopidor sh -c 'bin/rails db:environment:set RAILS_ENV=development; ruby bin/docker db:setup'

# Run all services
docker compose -f docker-compose.yml -f docker-compose-dev.yml up -d
```

###### Volumes

The volumes are named volumes, so they are not in the current project folder.

To delete them, do : ``docker compose -f docker-compose.yml -f docker-compose-dev.yml down -v``

#### Production mode

```bash
# build image
docker compose build dmpopidor

# Configure database connection for postgres
docker compose run --rm dmpopidor sh -c 'ruby bin/docker postgres'

# Setup database
docker compose run --rm dmpopidor sh -c 'ruby bin/docker db:setup'

# Run all services
docker compose up -d
```

The rails server is launched via puma behind a niginx, it is accessible at the url ``http://localhost:8080``

###### Volumes

The volumes are named volumes, so they are not in the current project folder.

To delete them, do : ``docker compose down -v``

#### Tests & Swagger/OpenAPI
The tests are run by [rswag](https://github.com/rswag/rswag), which generates OpenAPI documentation based on these tests.

An **rswag** command is defined in the ``Procfile.dev`` file to generate the OpenAPI file.

You can generate the OpenAPI file and run the tests with the following command:

```bash
docker compose -f docker-compose.yml -f docker-compose-dev.yml exec dmpopidor sh -c "RAILS_ENV=test rails rswag"
```

#### Troubleshooting
See the [Troubleshooting Guide](https://github.com/DMPRoadmap/roadmap/wiki/Troubleshooting) on the Wiki.

#### Support
Issues should be reported here on [Github Issues](https://github.com/DMPRoadmap/roadmap/issues)
Please be advised though that we can only provide limited support for your local installations.
Any security patches and bugfixes will be applied to the most recent version, and we will endeavour to support migrations to the current release.

#### Contributing
If you would like to contribute to the project. Please follow these steps to submit a contribution:
* Comment on the Github issue (or create one if one does not exist) and let us know that you're working on it.
* Fork the project (if you have not already) or rebase your fork so that it is up to date with the current repository's '_**development**_' branch
* Create a new branch in your fork. This will ensure that you are able to work at your own pace and continue to pull in any updates made to this project.
* Make your changes in the new branch
* When you have finished your work, make sure that your version of the '_**development**_' branch is still up to date with this project. Then merge your new branch into your '_**development**_' branch.
* Then create a new Pull Request (PR) from your branch to this project's '_**development**_' branch in GitHub
* The project team will then review your PR and communicate with you to convey any additional changes that would ensure that your work adheres to our guidelines.

See the [Contribution Guide](https://github.com/DMPRoadmap/roadmap/blob/development/CONTRIBUTING.md) on the Wiki for more details.

#### License
The DMP Roadmap project uses the <a href="./LICENSE.md">MIT License</a>.
