Gem::Specification.new do |s|
  s.name        = "rack-colorized_logger"
  s.version     = "1.0.3"
  s.authors     = ['Kenichi Nakamura']
  s.email       = ["kenichi.nakamura@gmail.com"]
  s.homepage    = "https://github.com/kenichi/rack-colorized_logger"
  s.summary     = "simple logger that outputs params, session, and cookies in fancy colors."
  s.files        = Dir["lib/**/*"]
  s.require_path = "lib"
  s.required_rubygems_version = ">= 1.4.2"
  s.add_dependency 'term-ansicolor'
end
