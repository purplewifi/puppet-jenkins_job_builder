# Author::    Liam Bennett  (mailto:lbennett@opentable.com)
# Copyright:: Copyright (c) 2013 OpenTable Inc
# License::   MIT

# == Class jenkins_job_builder::defaults
#
# This class is meant to be called from jenkins_job_builder
#
# You can provide a set of defaults that will be applied to all jenkins jobs;
# https://jenkins-job-builder.readthedocs.io/en/latest/definition.html#defaults
#
# example:
# jenkins_job_builder::defaults::config:
#    publishers:
#      - postbuildscript:
#          builders:
#            - build-on:
#                - SUCCESS
#              build-steps:
#                - shell: "echo 'yay!'"
#
class jenkins_job_builder::defaults (
  $config = $jenkins_job_builder::defaults
) {
  $defaults = merge({
      'name' => 'global',
  }, $config)

  $content = template('jenkins_job_builder/jenkins-defaults-yaml.erb')
  file { '/tmp/jenkins-defaults.yaml':
    ensure  => file,
    content => $content,
  }
}
