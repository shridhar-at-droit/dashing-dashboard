#!/usr/bin/env ruby
require 'net/http'
require 'uri'

# Check whether a server is responding
# you can set a server to check via http request or ping
#
# server options:
# name: how it will show up on the dashboard
# url: either a website url or an IP address (do not include https:// when usnig ping method)
# method: either 'http' or 'ping'
# if the server you're checking redirects (from http to https for example) the check will
# return false

annotator_dev_servers = [{name: 'ui', url: 'https://annotator-ui-dev.dit.droitfintech.net/status', method: 'http'},
	{name: 'document service', url: 'https://annotator-ds-dev.dit.droitfintech.net/index.html', method: 'http'},
	{name: 'neo4j', url: 'https://neo4j-dev.dit.droitfintech.net/browser/', method: 'http'},
]

annotator_uat_servers = [{name: 'ui', url: 'https://annotator-ui-uat.dit.droitfintech.net/status', method: 'http'},
	{name: 'document service', url: 'https://annotator-ds-uat.dit.droitfintech.net/index.html', method: 'http'},
	{name: 'neo4j', url: 'https://neo4j-uat.dit.droitfintech.net/browser/', method: 'http'},
]

portal_dev_servers = [{name: 'fronted', url: 'https://portal-dev.dit.droitfintech.net/index.html', method: 'http'},
	{name: 'backend', url: 'https://portal-backend-dev.dit.droitfintech.net/ping', method: 'http'},
]

devops_servers = [{name: 'Jenkins', url: 'http://jenkins-service:8080/robots.txt', method: 'http'},
		{name: 'Nexus', url: 'https://nexus-repo.dit.droitfintech.net/', method: 'http'},
        {name: 'Grafana', url: 'https://grafana.dit.droitfintech.net/login', method: 'http'},
        {name: 'Dependency Track', url: 'https://dependency-track.dit.droitfintech.net/login', method: 'http'},
        {name: 'Prometheus', url: 'https://prometheus.dit.droitfintech.net/graph', method: 'http'},
		{name: 'Graphite', url: 'https://graphite.dit.droitfintech.net/', method: 'http'},
		{name: 'Scope', url: 'https://scope.dit.droitfintech.net/', method: 'http'},
	]
# check status for each server
def status_check(servers)

	statuses = Array.new
	servers.each do |server|
		if server[:method] == 'http'
			uri = URI.parse(server[:url])
            http = Net::HTTP.new(uri.host, uri.port)
         
			if uri.scheme == "https"
				http.use_ssl=true
				http.verify_mode = OpenSSL::SSL::VERIFY_NONE
            end
            begin
			request = Net::HTTP::Get.new(uri.request_uri)
            response = http.request(request)
		    
			if response.code == "200"
			 	result = 1
			 else
			 	result = 0
			 end
			rescue
				print $!
				result = 0
			end
		elsif server[:method] == 'ping'
			ping_count = 10
			result = `ping -q -c #{ping_count} #{server[:url]}`
			if ($?.exitstatus == 0)
				result = 1
			else
				result = 0
			end
		end

		if result == 1
			arrow = "icon-ok-sign"
			color = "green"
		else
			arrow = "icon-warning-sign"
			color = "red"
		end
 
        statuses.push({label: server[:name], value: result, arrow: arrow, color: color})
        puts "statuses #{statuses}"
	end
	return statuses
end

SCHEDULER.every '300s', :first_in => 0 do |job|
send_event('annotator_dev_status', {items: status_check(annotator_dev_servers)})
send_event('annotator_uat_status', {items: status_check(annotator_uat_servers)})	 
send_event('devops_status', {items: status_check(devops_servers)})
send_event('portal_status', {items: status_check(portal_dev_servers)})
end