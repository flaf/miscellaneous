#==Action
#
# Install Airtime. Tested with Debian Wheezy.
# It's a web interface to upload audio files and
# schedule broadcasting via icecast. So this class
# involves the icecast installation on the same
# sever.
#
# /!\ This puppet class depends on: /!\
# - repositories::sourcefabric to add the airtime repository.
# - "icecast2" class. Don't include this class yourself because
#   you can have error because of ordering problem. The "airtime"
#   class will iutomatically nclude the "icecast2" class in the
#   good moment to avoid ordering errors.
#
#
#==Hiera
#
#airtime:
#  port: 8080 # this entry is optional and the default is 8080.
#
#
class airtime {

  include 'airtime::install'
  include 'airtime::apache2'
  include 'airtime::config'
  include 'airtime::services'
  include 'icecast2'

  Class['airtime::install']
   -> Class['airtime::apache2']
   -> Class['airtime::config']
   -> Class['airtime::services']
   -> Class['icecast2']

}


