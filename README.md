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

## sys11lib::deprecated::deprecated_set

### Parameters:

    $old = ''
      old thing to be deprecated
    $new = ''
      new thing to use instead
    $add = ''
      optional additional thins to say

### Sample Usage (Manifest):

    sys11lib::deprecated::deprecated_set { 'nginx->nginx2':
      old => 'nginx',
      new => 'nginx2',
    }