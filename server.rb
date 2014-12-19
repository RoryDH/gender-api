require 'json'
require 'sinatra'
require 'sinatra/cross_origin'
require 'gender_detector'

enable :logging
configure do
  enable :cross_origin
end

$gd = GenderDetector.new(case_sensitive: false)
GENDER_FORMAT = {
  male:          'm',
  mostly_male:   'm',
  female:        'f',
  mostly_female: 'f',
  andy:          'n'
}

def req_json  
  return @req_json if @req_json
  request.body.rewind
  @req_json = JSON.parse(request.body.read)
end

def error(s)
  { error: s }
end

get '/' do
  "Rory's gender server. Time: #{Time.now}. Uses https://github.com/bmuller/gender_detector"
end

post '/bulk' do
  names = req_json['names']
  return error('Invalid Request') unless names && names.is_a?(Array)
  
  gender_map = {}
  names.uniq.each do |name|
    gender_map[name] = GENDER_FORMAT[$gd.get_gender(name, :ireland)]
  end

  logger.info("#{gender_map.size} names (like #{names[0]})")
  { names: gender_map }.to_json
end
