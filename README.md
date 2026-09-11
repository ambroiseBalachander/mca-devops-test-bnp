**⚠️ DO NOT FORK THIS REPOSITORY! ⚠️** \
**⚠️ DO NOT OPEN A PULL REQUEST! ⚠️** \
**Publish on GitHub as a __private__ repository shared (Settings>Collaborators>Manage access) with @zigarn, @charlecoms & @Sekokp.**

# MCA DevOps test

We have a classic N-tier application:

- a [backend](./backend/): a Java/SpringBoot 3/Maven application exposing endpoints to list and add users
- a [frontend](./frontend/): an Angular application to interact with the backend
- a PostgreSQL database

## Instructions

Deploy the backend, frontend and PostgreSQL database on a Kubernetes cluster of your choice.

PostgreSQL credentials must be "`myapplication`" and "`M3P@ssw0rd!`".

## Deliverables

A **private** GitHub repository (shared with @zigarn, @charlecoms & @Sekokp) containing:

- Dockerfiles for backend and frontend
- Files to perform the deployment of the full stack in Kubernetes
- A `SOLUTION.md` with:
  - build steps
  - deployment steps
  - a screenshot of the frontend UI showing a non-empty list of users

## Guidelines

- Keep it simple and don't overcomplicate things. For example, no need to try to hide the environment variables.
- AI assistance is allowed but must be mentionned and you must understand and control all the aspects of the solution.

## Bonus tasks

- CI Pipeline: automate builds with a CI tool of your choice (see [jenkins](./jenkins/) to setup a Jenkins inside your Kubernetes cluster)
- ansible Playbook: deploy the stack to Kubernetes using ansible
