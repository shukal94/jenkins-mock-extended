#!/usr/bin/env coffee

express = require 'express'
api = require "#{__dirname}/api"
config = require './config'

app = express()

app.get config.CONFIG.CONTEXT_PATH + "/api/json", api.getJobs

app.get config.CONFIG.CONTEXT_PATH + "/job/:job/api/json", api.getJob

# https://ci.jenkins-ci.org/view/Jenkins%20core/job/jenkins_main_trunk/2155/api/json
app.get config.CONFIG.CONTEXT_PATH + "/job/:job/:build/api/json", api.getBuild

app.get config.CONFIG.CONTEXT_PATH + "/job/create", api.createJob

app.get config.CONFIG.CONTEXT_PATH + "/job/:job/createBuild", api.createJobBuild

app.post config.CONFIG.CONTEXT_PATH + "/job/:job/buildWithParameters/api/json", api.buildWithParameters

app.post config.CONFIG.CONTEXT_PATH + "/job/:job/:build/stop/api/json", api.abort

app.get config.CONFIG.CONTEXT_PATH + "/job/:job/:build/logText/progressiveHtml/api/json", api.getBuildConsoleOutput

app.listen config.CONFIG.PORT
console.log "Server started on port " + config.CONFIG.PORT
