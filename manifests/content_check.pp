define enable_http_content_check ( $domain, $path, $content, $timeout ) {
	nagios::nrpecmd { "check_http_content_$name":
		cmd => "/usr/lib/nagios/plugins/check_http -H '$domain' -I $ipaddress_internal -u '$path' -s '$content' -t $timeout"
	}
}

class sys11lib::content_check ( $domain, $path, $content, $timeout=45 ) {
	enable_http_content_check { 'default':
		domain => $domain,
		path => $path,
		content => $content,
		timeout => $timeout,
	}
  nagios::register_hostgroup{ "$customer.$project.content_check": }
}
