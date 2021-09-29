# Kopytko Framework

Kopytko Framework is a simple framework created to build simpler and cleaner components in Roku SceneGraph,
allowing you to write component code declaratively instead of imperatively, leading to a less error-prone codebase
and improving its maintainability overall. It is highly inspired by the Javascript library React and follows a lot
of its patterns as well as its API, making it extremely friendly for someone coming from a React components environment.
It is also inspired by router of the Javascript Angular framework and some other mechanisms taken from the Javascript world.

Kopytko Framework is part of Kopytko Roku Ecosystem which consists of:
- [Kopytko Framework](https://github.com/getndazn/kopytko-framework),
- [Kopytko Utils](https://github.com/getndazn/kopytko-utils) - a collection of modern utility functions for Brightscript applications,
- [Kopytko Packager](https://github.com/getndazn/kopytko-packager) - a package builder for the Roku platform,
- [Kopytko Unit Testing Framework](https://github.com/getndazn/kopytko-unit-testing-framework) - extended Roku's Unit Testing Framework with additional assert functionalities and the mocking mechanism,
- [Kopytko ESLint Plugin](https://github.com/getndazn/kopytko-eslint-plugin) - set of Brightscript rules for ESLint

Kopytko Framework, Utils and Unit Testing Framework are exportable as Kopytko Modules, so they can easily be installed
and used in apps configured by Kopytko Packager.

## Modules

- Renderer: main module, inspired by JS React library, rendering components. Full documentation available in
  [docs/renderer.md](docs/renderer.md)
- Router: enables building an app with multiple views and allows navigation between them
- Cache: a mechanism to store expirable external data
- Event Bus: implementation of Event Bus simplifying the communication between components
- HTTP: easy way to send HTTP requests
- Modal: global UI component
- Registry: a facade over native Roku's registry
- Store: a mechanism to store reusable data
- Theme: manages UI configuration and allows easy use in any place

