require 'net/http'
require 'json'

bundler_list = `bundle list`
locked_gems = bundler_list.split("\n").map(&:strip) - ["Gems included by the bundle:"]

gemfile = File.read('Gemfile')

locked_gems.each do |gem_info|
  entry = gem_info.delete("*").split(' ')
  gem = entry.first
  version = entry.last.delete('(').delete(')')

  next unless gem && gemfile.include?("gem '#{gem}'")

  response = Net::HTTP.get(URI("https://rubygems.org/api/v1/gems/#{gem}.json"))

  data = JSON.parse(response)

  puts [
    gem,
    data['project_uri'],
    data['version'],
    data['version_created_at'].split('T').first,
    (data['licenses'] || []).join(', '),
    version,
    data['yanked'] ? 'YANKED' : ''
  ].map(&:to_s).join("\t")
end
