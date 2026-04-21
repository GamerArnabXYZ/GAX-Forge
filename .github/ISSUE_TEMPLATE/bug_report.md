name: Bug Report
description: Create a bug report to help us improve
labels: bug
body:
  - type: markdown
    attributes:
      value: |
        Thanks for taking the time to fill out this bug report!

        **Please describe the bug:**
        A clear and concise description of what the bug is.

        **To Reproduce:**
        Steps to reproduce the behavior:
        1. Go to '...'
        2. Click on '....'
        3. See error

        **Expected behavior:**
        A clear description of what you expected to happen.

        **Screenshots:**
        If applicable, add screenshots to help explain your problem.

        **Device information:**
        - Device: [e.g. Pixel 6, iPhone 14]
        - OS: [e.g. Android 14, iOS 17]
        - Flutter version: [e.g. 3.16.0]

        **Additional context:**
        Add any other context about the problem here.
  - type: textarea
    id: description
    attributes:
      label: Bug Description
      description: What's the issue?
      placeholder: Describe the bug...
    validations:
      required: true
