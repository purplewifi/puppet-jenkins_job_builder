# Author::    Liam Bennett  (mailto:lbennett@opentable.com)
# Copyright:: Copyright (c) 2013 OpenTable Inc
# License::   MIT

# == Class jenkins_job_builder::config
#
# This class is meant to be called from jenkins_job_builder
# It sets the global ini file used by jenkins_job_builder
#
class jenkins_job_builder::config (
  $jobs = $jenkins_job_builder::jobs,
  $user = $jenkins_job_builder::user,
  $password = $jenkins_job_builder::password,
  $timeout  = $jenkins_job_builder::timeout,
  $hipchat_token = $jenkins_job_builder::hipchat_token,
  $jenkins_url = $jenkins_job_builder::jenkins_url,
  $tmp_dir = $jenkins_job_builder::tmp_dir,
) {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  file { '/etc/jenkins_jobs':
    ensure => directory,
  }

  file { 'ensure jjb tmp dir':
    ensure => directory,
    path   => $tmp_dir,
  }

  # Clean up jenkins- files from the tmp dir, just in case any jobs have been
  # removed. This allows crons to maintain/revert the jobs in jenkins, to match
  # expectations in code.
  exec { 'clean jjb tmp dir':
    command => "/bin/bash -c 'rm -f ${tmp_dir}/jenkins-*.yaml'",
  }

  file { '/etc/jenkins_jobs/jenkins_jobs.ini':
    ensure  => file,
    require => File['/etc/jenkins_jobs'],
  }

  ini_setting { 'jenkins-jobs user':
    ensure  => present,
    path    => '/etc/jenkins_jobs/jenkins_jobs.ini',
    section => 'jenkins',
    setting => 'user',
    value   => $user,
    require => File['/etc/jenkins_jobs/jenkins_jobs.ini'],
  }

  ini_setting { 'jenkins-jobs password':
    ensure  => present,
    path    => '/etc/jenkins_jobs/jenkins_jobs.ini',
    section => 'jenkins',
    setting => 'password',
    value   => $password,
    require => File['/etc/jenkins_jobs/jenkins_jobs.ini'],
  }

  ini_setting { 'jenkins-jobs url':
    ensure  => present,
    path    => '/etc/jenkins_jobs/jenkins_jobs.ini',
    section => 'jenkins',
    setting => 'url',
    value   => $jenkins_url,
    require => File['/etc/jenkins_jobs/jenkins_jobs.ini'],
  }

  if $timeout {
    $ensure_timeout = 'present'
  } else {
    $ensure_timeout = 'absent'
  }

  ini_setting { 'jenkins-jobs timeout':
    ensure  => $ensure_timeout,
    path    => '/etc/jenkins_jobs/jenkins_jobs.ini',
    section => 'jenkins',
    setting => 'timeout',
    value   => $timeout,
    require => File['/etc/jenkins_jobs/jenkins_jobs.ini'],
  }

  ini_setting { 'jenkins-jobs hipchat token':
    ensure  => present,
    path    => '/etc/jenkins_jobs/jenkins_jobs.ini',
    section => 'hipchat',
    setting => 'authtoken',
    value   => $hipchat_token,
    require => File['/etc/jenkins_jobs/jenkins_jobs.ini'],
  }

  contain jenkins_job_builder::defaults
  create_resources('jenkins_job_builder::job', $jobs)
}
