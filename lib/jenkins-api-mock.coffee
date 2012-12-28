#!/usr/bin/env coffee

express = require 'express'
api = require "#{__dirname}/api"


CONFIG =
  CONTEXT_PATH: ''
  PORT: 8000

app = express()

app.get "#{CONFIG.CONTEXT_PATH}/api/json", api.getJobs

app.get "#{CONFIG.CONTEXT_PATH}/job/:job/api/json", api.getJob

# https://ci.jenkins-ci.org/view/Jenkins%20core/job/jenkins_main_trunk/2155/api/json
app.get "#{CONFIG.CONTEXT_PATH}/job/:job/:build/api/json", api.getBuild

app.get "#{CONFIG.CONTEXT_PATH}/job/create", api.createJob

app.get "#{CONFIG.CONTEXT_PATH}/job/:job/createBuild", api.createJobBuild

app.listen CONFIG.PORT
console.log "Server started on port #{CONFIG.PORT}..."