Puppet::Type.type(:rabbitmq_plugin).provide(:rabbitmqplugins) do

  defaultfor :feature => :posix

  # Fix Puppet 3.0 #16779, pass $HOME to rabbit command.
  if Puppet::Util::Package.versioncmp(Puppet.version, '3.0') >= 0
    has_command(:rabbitmqplugins, 'rabbitmq-plugins') do
      environment 'HOME' => Puppet[:vardir]
    end
  else
    commands :rabbitmqplugins => 'rabbitmq-plugins'
  end

  def self.instances
    rabbitmqplugins('list', '-E').split(/\n/).map do |line|
      if line.split(/\s+/)[1] =~ /^(\S+)$/
        new(:name => $1)
      else
        raise Puppet::Error, "Cannot parse invalid plugins line: #{line}"
      end
    end
  end

  def create
    rabbitmqplugins('enable', resource[:name])
  end

  def destroy
    rabbitmqplugins('disable', resource[:name])
  end

  def exists?
    out = rabbitmqplugins('list', '-E').split(/\n/).detect do |line|
      line.split(/\s+/)[1].match(/^#{resource[:name]}$/)
    end
  end

end
