# Contributing Guidelines

Welcome, and thanks in advance for your help! Please follow these simple guidelines :+1:

# How to contribute

## When you propose a new feature or bug fix

**Note:** Please make sure to write an issue first and get enough feedback before jumping into a Pull Request!

- Please make sure there is an open issue discussing your contribution
- If there isn't, please open an issue so we can talk about it before you invest time into the implementation
- When creating an issue follow the guide that GitHub shows so we have enough information about your proposal

## When you want to work on an existing issue

**Note:** Please write a quick comment in the corresponding issue and ask if the feature is still relevant and that you want to jump into the implementation.

Check out our [help wanted](https://github.com/getndazn/kopytko-utils/labels/help%20wanted) or [good first issue](https://github.com/getndazn/kopytko-utils/labels/good%20first%20issue) labels to find issues we want to move forward on with your help.

We will do our best to respond/review/merge your PR according to priority. We hope that you stay engaged with us during this period to insure QA. Please note that the PR will be closed if there hasn't been any activity for a long time (~ 30 days) to keep us focused and keep the repo clean.

## Reviewing Pull Requests

Another really useful way to contribute to this project is to review other peoples Pull Requests. Having feedback from multiple people is really helpful and reduces the overall time to make a final decision about the Pull Request.

## Writing / improving documentation

Our documentation lives in the README file. Do you see a typo or other ways to improve it? Feel free to edit it and submit a Pull Request!

---

# Code Style

We aim for clean, consistent code style. We're using ESlint to check for codestyle issues (you can run `npm run lint` to lint your code).

To help reduce the effort of creating contributions with this style, an [.editorconfig file](http://editorconfig.org/) is provided that your editor may use to override any conflicting global defaults and automate a subset of the style settings.

# Commit messages

This project uses `Semantic release` to publish NPM updates and generate [CHANGELOG](CHANGELOG.md). For these to work, it depends on [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0-beta.3).

As such, when you create a PR, you should make sure your commits follow the convention of: `<type>: <description>`.

For example:

* A bug fix should read:

```text
fix: some description.
```

* A new feature should read:

```text
feat: some description.
```

* A new breaking change should read:

```text
feat!: some description.
```

* A `README.md` (this file) change should read:

```text
docs: added Contribution Guide.
```

* A change to the build pipeline (e.g. `semantic.yml`) should read:

```text
build: some description.
```

* Other misc chores should read:

```text
chore: some description.
```

# Our Code of Conduct

Finally, to make sure you have a pleasant experience while being in our welcoming community, please read our [code of conduct](CODE_OF_CONDUCT.md). It outlines our core values and believes and will make working together a happier experience.

Thanks again for being a contributor to the community :tada:!

Cheers,
