Change Evidence
==============

![Last tested in Nuix 7.8](https://img.shields.io/badge/Nuix-7.8-green.svg)

View the GitHub project [here](https://github.com/Nuix/Change-Evidence) or download the latest release [here](https://github.com/Nuix/Change-Evidence/releases).

# Overview

This script finds the evidence XML files associated with a case's evidence containers and allows the user to set new evidence paths. Useful when drive mappings change or data is moved.

# Getting Started

## Setup

Begin by downloading the latest release of this code.  Extract the contents of the archive into your Nuix scripts directory.  In Windows the script directory is likely going to be either of the following:

- `%appdata%\Nuix\Scripts` - User level script directory
- `%programdata%\Nuix\Scripts` - System level script directory

## Usage

This script will:
- Find the XML file for each evidence container (includes subcases with compound cases).
- Show each current path and ask if you want to change it.
- Ask if you want to backup the XML file (saved to the same location with <timestamp>.BAK appended).
- Prompt to select new path.
- Confirm old and new paths.
- Update evidence XML file.
- Note that the case must be closed and re-opened for changes to take effect.

# License

```
Copyright 2019 Nuix

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
