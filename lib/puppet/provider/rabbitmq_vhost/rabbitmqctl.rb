Puppet::Type.type(:rabbitmq_vhost).provide(:rabbitmqctl) do

  defaultfor :feature => :posix

  # Fix Puppet 3.0 #16779, pass $HOME to rabbit command.
  if Puppet::Util::Package.versioncmp(Puppet.version, '3.0') >= 0
    has_command(:rabbitmqctl, 'rabbitmqctl') do
      environment 'HOME' => Puppet[:vardir]
    end
  else
    commands :rabbitmqctl => 'rabbitmqctl'
  end

  def self.instances
    rabbitmqctl('list_vhosts').split(/\n/)[1..-2].map do |line|
      if line =~ /^(\S+)$/
        new(:name => $1)
      else
        raise Puppet::Error, "Cannot parse invalid user line: #{line}"
      end
    end
  end

  def create
    rabbitmqctl('add_vhost', resource[:name])
  end

  def destroy
    rabbitmqctl('delete_vhost', resource[:name])
  end

  def exists?
    out = rabbitmqctl('list_vhosts').split(/\n/)[1..-2].detect do |line|
      line.match(/^#{Regexp.escape(resource[:name])}$/)
    end
  end

end
