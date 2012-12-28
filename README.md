# jenkins-api-mock

This project mocks a jenkins server. The intention of this project was a test driver for https://github.com/knalli/pi-jenkins.

# Usage
Start the server with `npm start`. However, this is only a shortcut which executes `lib/jenkins-api-mock.coffee` using CoffeeScript.

The port of the server is `8000`.

## Overview
`GET http://localhost:8000/api/json` returns an object of the (master) node. This inconcludes the property `jobs` with an array of all defined jobs.

## Get Job Details
`GET http://localhost:8000/job/:jobName/api/json` returns an object of the job with the id/name `jobName`. This inconcludes the property `builds` with an array of all run builds.

## Get Job Build Details
`GET http://localhost:8000/job/:jobName/:build/api/json` returns an object of the job's build with the id/name `jobName` and the build query `build`. The last parameter can be either an existing build number of a symbolic link like `lastStableBuild`.

## Create Job
`GET http://localhost:8000/job/create?name=:name` creates a new job with a `name`. This returns the job just like the read variant.

## Create Job Build
`GET http://localhost:8000/job/:jobName/createBuild?duration=:duration&result=:result` creates a new build for `jobName`. Use the option `duration` for a deferred build finish, `result` for a specific result (`SUCCESS` as default, see [Jenkins API](http://javadoc.jenkins-ci.org/hudson/model/Result.html).

Note: Yep, the modifying commands aren't very well REST like. But this have to be a nice test driver utility which have to be works in a browser as well in CLI environments.

## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Lint and test your code using [grunt](https://github.com/gruntjs/grunt).

## Release History
_(Nothing yet)_

## License
Copyright (c) 2012 Jan Philipp
Licensed under the MIT license.
