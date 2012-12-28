APP = 'Jenkins API Mock'

# http://javadoc.jenkins-ci.org/hudson/model/Result.html
VALID_RESULTS = ['ABORTED', 'FAILURE', 'NOT_BUILT', 'SUCCESS', 'UNSTABLE']

COLORS =
  RED: 'red'
  BLUE: 'blue'
  ABORTED: 'aborted'
  DISABLED: 'disabled'
  YELLOW: 'yellow'
  GREY: 'grey'

workspace = jobs: null

workspace.jobs = {}

workspace.createJob = ({name, displayName}) ->
  return unless name
  job =
    actions: [],
    description: ''
    displayName: name,
    displayNameOrNull: displayName ? name
    name: name
    buildable: true
    builds: []
    color: 'blue'
    firstBuild: null
    lastBuild: null
    lastCompletedBuild: null
    lastFailedBuild: null
    lastStableBuild: null
    lastUnstableBuild: null
    nextBuildNumber: 1
  workspace.jobs[name] = job

###
  Create a new build for the specified job.
  @param Number   name
                  The name of the job.
  @param Number   options.duration
                  Defines a deferred completion of the build. This'd be a more realistic build. 1 as default.
  @param String   options.result
                  Defines the build's result. This must be a value of the VALID_RESULTs. 'STABLE' will be assumed as default.
  @param Object
                  Returns the new build (however, without the new state because this will be deferred).
###
workspace.createJobBuild = (name, {duration, result}) ->
  return unless name or result in VALID_RESULTS
  job = workspace.jobs[name]
  return unless job
  job.building = true
  build =
    number: job.nextBuildNumber++
    result: null
    timestamp: new Date().getTime()
  job.builds.push build
  fn = ->
    build.result = result ? 'SUCCESS'
    workspace._onUpdateJob job.name
  setTimeout fn, duration ? 1
  build

###
  Internal sync updating the job meta data regarding this latest job build result.
###
workspace._onUpdateJob = (name) ->
  job = workspace.jobs[name]
  job.building = false
  return unless job
  for build in job.builds
    job.firstBuild = build unless job.firstBuild
    switch build.result
      when 'ABORTED'
        job.lastBuild = number: build.number
        job.color = COLORS.ABORTED
      when 'FAILURE'
        job.lastBuild = number: build.number
        job.lastCompletedBuild = number: build.number
        job.lastFailedBuild = number: build.number
        job.color = COLORS.RED
      when 'SUCCESS'
        job.lastBuild = number: build.number
        job.lastCompletedBuild = number: build.number
        job.lastStableBuild = number: build.number
        job.color = COLORS.BLUE
      when 'UNSTABLE'
        job.lastBuild = number: build.number
        job.lastCompletedBuild = number: build.number
        job.lastUnstableBuild = number: build.number
        job.color = COLORS.YELLOW
      else
        job.lastBuild = number: build.number
        job.color = COLORS.GREY
  return

workspace.getJob = (name) -> workspace.jobs[name]

workspace.getJobs = (full = false) ->
  jobs = []
  for own name, job of workspace.jobs
    if full
      jobs.push job
    else
      jobs.push name: job.name, color: job.color
  jobs

workspace.getJobBuild = (searchJobName, searchBuildQuery) ->
  job = workspace.jobs[searchJobName]
  return unless job
  if parseInt searchBuildQuery isnt NaN
    (build for build in job.builds when build.number is searchBuildQuery)[0]
  else
    workspace._findJobBuildByQuery job.builds, searchBuildQuery

workspace._findJobBuildByQuery = (builds, query) ->
  result = []
  for build in builds
    switch build.result
      when 'ABORTED'
        result.push build if query in ['lastBuild']
      when 'FAILURE'
        result.push build if query in ['lastBuild', 'lastCompletedBuild', 'lastUnsuccessfulBuild', 'lastFailedBuild']
      when 'SUCCESS'
        result.push build if query in ['lastBuild', 'lastCompletedBuild', 'lastSuccessfulBuild', 'lastStableBuild']
      when 'UNSTABLE'
        result.push build if query in ['lastBuild', 'lastCompletedBuild', 'lastSuccessfulBuild', 'lastUnstableBuild']
      else
        result.push build if query in ['lastBuild']
  result[result.length - 1]

exports.createJob = (req, res) ->
  job = workspace.createJob req.query
  if job
    res.send job
  else
    res.send 500, "#{APP}: The request could not be completed."

exports.createJobBuild = (req, res) ->
  build = workspace.createJobBuild req.params.job, req.query
  if build
    res.send build
  else
    res.send 500, "#{APP}: The request could not be completed."

exports.getJobs = (req, res) ->
  jobs = workspace.getJobs()
  if jobs
    res.send
      mode: 'EXCLUSIVE'
      nodeDescription: 'Jenkins Master-Node'
      nodeName: ''
      numExecutors: 2
      description: null
      jobs: jobs
  else
    res.send 404, "#{APP}: The requested server is not available."

exports.getJob = (req, res) ->
  job = workspace.getJob req.params.job
  if job
    res.send job
  else
    res.send 404, "#{APP}: The requested job #{req.params.job} is not available."

exports.getBuild = (req, res) ->
  build = workspace.getJobBuild req.params.job, req.params.build
  if build
    res.send build
  else
    res.send 404, "#{APP}: The requested build #{req.params.job}/#{req.params.build} is not available."
