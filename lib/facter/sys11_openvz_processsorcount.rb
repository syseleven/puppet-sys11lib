# Matthias Baur, m.baur@syseleven.de @2017
# Works as designed!
# This is a helper script to retrieve the openvz processorcount which is currently not possible with Facter 3.
# See https://tickets.puppetlabs.com/browse/FACT-1091 for more information.

Facter.add("sys11_openvz_processsorcount") do
  confine :kernel => [ :linux, ]
  setcode do
    processor_num = -1
    processor_list = []
    cpuinfo='/proc/cpuinfo'
    if File.exists?(cpuinfo)
      model = Facter.value(:architecture)
      case model
        when "x86_64", "amd64", "i386", "x86", /parisc/, "hppa", "ia64"
          File.readlines(cpuinfo).each do |l|
            if l =~ /processor\s+:\s+(\d+)/
              processor_num = $1.to_i
            elsif l =~ /model name\s+:\s+(.*)\s*$/
              processor_list[processor_num] = $1 unless processor_num == -1
              processor_num = -1
            elsif l =~ /processor\s+(\d+):\s+(.*)/
              processor_num = $1.to_i
              processor_list[processor_num] = $2 unless processor_num == -1
            end
          end
      end
    end

    ## If this returned nothing, then don't resolve the fact
    processor_list.length.to_s
    if processor_list.length != 0
      processor_list.length
    end
  end
end
