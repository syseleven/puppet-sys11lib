# Sys11lib

Internal sys11 library for several puppet classes and functions.

* Sys11lib puppet module [changelog](CHANGELOG)

# Functions

## dirname()

Returns all components of the filename given as argument except the last one. The filename must be formed using forward slashes (``/..) regardless of the separator used on the local file system.

### Usage

    dirname(string) : string
    dirname(string[]) : string[]

# Classes

## sys11lib::content_check

Enables a http content check via nagios. This checks if a certain URL returns certain content. There is also a define for this:

    enable_http_content_check ( $domain, $path, $content, $timeout ) 

## sys11lib::ensure_key_value

This define allows to manipulate text files that contain key value pairs separated by $delimiter. Ensures that $file contains the line *$key$delimiter$value*. If a line exists that starts with $key$delimiter it is replaced by the above line.

### Parameters

    $file
      file the file to edit
    $key
    $value
    $ensure = 'present'
      state if key and value shall be in file (present and absent supported)
    $delimiter = ' '
      a regular expression as delimiter between key and value

### Sample usage

    ensure_key_value { "/etc/make.conf":
      file      => '/etc/make.conf',
      delimiter => '=',
      key       => 'CFLAGS',
      value     => "'-O2 -g --pipe'"
    }

Double quotes are not allowed, use single quotes for inside values!

## sys11lib::ve_name

Puts */.ve-name* in the root directory of the VE containing the VE's name.

## sys11lib::wget

A Puppet module to download files with wget, supporting authentication. This module contains the wget provider, to use wget, you use sys11lib::wget.

### Sample usage

     sys11lib::wget:
       pkg:
         '/var/www/klobana'
           source: 'https://github.com/klobana'

## sys11lib::deprecated

Helper module to easily throw notifies for deprecating warnings.

### Parameters:

    $set = {}
      Hash with deprecations

### Sample Usage (Sys11-ENC):

    sys11lib::deprecated:
      set:
        'loadbalancer->virtuozzo_ve/nginx2':
          old: 'Role "loadbalancer"'
          new: 'Role "virtuozzo_ve" with Class "nginx2"'
          add: 'These is additional messages which currently says really nothing.'

## sys11lib::deprecated_set

### Parameters:

    $old = ''
      old thing to be deprecated
    $new = ''
      new thing to use instead
    $add = ''
      optional additional thins to say

### Sample Usage (Manifest):

    sys11lib::deprecated_set { 'nginx->nginx2':
      old => 'nginx',
      new => 'nginx2',
    }

## sys11lib::ssl_certificate_check

### Parameters:

    $place_script = true
      place the script
    $enable_check = true
      enable the cronjob and the nagioscheck
    $enable_autodetection = true
      enable autodetection of running service, domains and certificates
    $blacklist_domains = ''
      blacklist (don't check) these domain(s)
    $blacklist_domains_file = ''
      blacklist (don't check) domain(s) listed in this file
    $whitelist_domains = ''
      whitelist (check) these domain(s)
    $whitelist_domains_file = ''
      whitelist (check) domain(s) listed in this file
    $blacklist_certificates = ''
      blacklist (don't check) these certificate(s)
    $blacklist_certificates_file = ''
      blacklist (don't check) certificate(s) listed in this file
    $service = ''
      specify the running service. this is usefull if SSL is not running
      on port 443
    $return_ok_when = 'A'
      return OK on nagios if the grade is one of these letters
    $return_warning_when = 'BC'
      return WARNING on nagios if the grade is one of these letters
    $return_critical_when = 'DEFT'
      return CRITICAL on nagios if the grade is one of these letters
    $ending_warning_limit = 21
      return WARNING when a certificate expires in less than these days
    $ending_critical_limit = 7
      return CRITICAL when a certificate expires in less than these days
    $curl_recheck_runs = 5
      specify how often the script tries to recheck if a curl fails
    $curl_recheck_interval = 10
      recheck the state of the check after this value in seconds
    $curl_recheck_timeout = 300
      abort the check after this value in seconds
    $cache_result_days = 7
      the default max cache age for results
    $cronjob_time = ''
      the script runs much longer than 45 seconds so we couln't check
      it via nagios directly, we had to use a cronjob. Recommendation
      is to keep the default. In this case puppet sets the value by
      using random values
