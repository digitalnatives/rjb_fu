
begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

task :default => 'test:run'
task 'gem:release' => 'test:run'

Bones {
  name     'rjb_fu'
  authors  'Digital Natives'
  email    'info@digitalnatives.hu'
  url      'http://www.digitalnatives.hu'

  depend_on 'rjb', :version => '>=1.2.0'
}

