package ISE::CiscoParse::Parser;

use warnings;
use strict;
use Parse::RecDescent;

=head1 NAME

ISE::CiscoParse::Parser - A L<Parse::RecDescent> parser for Cisco
configuration files

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

    use ISE::CiscoParse::Parser;
    my $parser = ISE::CiscoParse::Parser->new();
    ...

=head1 OBJECT METHODS

=head2 new()

=cut

sub new {
    my $class = shift;

    # create the Parse::RecDescent
    my $parser = Parse::RecDescent->new(<<'EOG'
        cfg_block :
            unnamed_interface
            | uplink_interface
            | trunk_interface

            | port_channel_interface
            | vlan_interface
            #| vpn_tunnel_interface
            #| shutdown_port_channel_interface
            # | simple_block # for testing

    ### BEGIN RULES
#    simple_block :
#        l_interface interface_name
#        l_description description
#        l_sp_access_vlan sp_access_vlan(s)
#        sp_trunk_encap
#        l_sp_trunk_native_vlan sp_trunk_native_vlan(s)
#        l_sp_trunk_allowed_vlan sp_trunk_allowed_vlan(s /,/)
#        sp_mode_trunk
#        { chomp(%item); $return = \%item }

        uplink_interface : # 3560-af155-c21b GigabitEthernet0/1
            l_interface interface_name
            l_description description
            l_sp_access_vlan sp_access_vlan
            sp_mode_access
            span_tree_pf
            { chomp(%item); $return = \%item }
        | # 6509-af155-d5a GigabitEthernet5/1
            l_interface interface_name
            l_description description
            "switchport"
            l_sp_access_vlan sp_access_vlan
            sp_mode_access
            "no ip address"
            { chomp(%item); $return = \%item }

        unnamed_interface :
            l_interface interface_name
            l_sp_access_vlan sp_access_vlan
            sp_mode_access
            span_tree_pf
            { chomp(%item); $return = \%item }

        trunk_interface :
            # 3560-af155-c21a GigabitEthernet0/4 & GigabitEthernet0/5
            l_interface interface_name
            l_description description
            l_sp_access_vlan(?) sp_access_vlan(?)
            l_sp_trunk_encap sp_trunk_encap
            l_sp_trunk_native_vlan sp_trunk_native_vlan
            l_sp_trunk_allowed_vlan sp_trunk_allowed_vlan(s /,/)
            sp_mode_trunk
            span_tree_pf
            { chomp(%item); $return = \%item }
        | # 6509-af155-d5a GigabitEthernet1/10
            l_interface interface_name
            l_description description
            switchport
            l_sp_access_vlan sp_access_vlan
            l_sp_trunk_encap sp_trunk_encap
            l_sp_trunk_native_vlan sp_trunk_native_vlan
            l_sp_trunk_allowed_vlan sp_trunk_allowed_vlan(s /,/)
            sp_mode_trunk
            no_ip_address
            span_tree_pf
            { chomp(%item); $return = \%item }
        | # 6509-af155-d5a GigabitEthernet4/5
            l_interface interface_name
            l_description description
            switchport
            l_sp_access_vlan sp_access_vlan
            l_sp_trunk_encap sp_trunk_encap
            l_sp_trunk_native_vlan sp_trunk_native_vlan
            l_sp_trunk_allowed_vlan sp_trunk_allowed_vlan(s /,/)
            sp_mode_trunk
            no_ip_address
            span_tree_pf
            "spanning-tree guard root"
            { chomp(%item); $return = \%item }
        | # 6509-af155-d5a GigabitEthernet4/16
            l_interface interface_name
            l_description description
            switchport
            l_sp_access_vlan sp_access_vlan
            l_sp_trunk_encap sp_trunk_encap
            no_ip_address
            span_tree_pf
            { chomp(%item); $return = \%item }

        port_channel_interface :
            # from 3560-af155-c21a GigabitEthernet0/17
            l_interface interface_name
            l_description description
            l_sp_access_vlan sp_access_vlan
            l_sp_trunk_encap sp_trunk_encap
            l_sp_trunk_native_vlan sp_trunk_native_vlan
            l_sp_trunk_allowed_vlan sp_trunk_allowed_vlan(s /,/)
            sp_mode_trunk
            l_ch_grp ch_grp l_ch_grp_mode ch_grp_mode
            span_tree_pf_disable
            { chomp(%item); $return = \%item }
        | # from 6509-af155-d5a Port-channel2
            l_interface pc_interface_name
            l_description description
            "switchport"
            l_sp_trunk_encap sp_trunk_encap
            l_sp_trunk_native_vlan sp_trunk_native_vlan
            sp_mode_trunk
            "no ip address"
            span_tree_pf_disable
            { chomp(%item); $return = \%item }
        | # from 6509-af155-d5a GigabitEthernet3/1
            l_interface interface_name
            l_description description
            "switchport"
            l_sp_trunk_encap sp_trunk_encap
            l_sp_trunk_native_vlan sp_trunk_native_vlan
            sp_mode_trunk
            "no ip address"
            span_tree_pf_disable
            l_ch_grp ch_grp l_ch_grp_mode ch_grp_mode
            { chomp(%item); $return = \%item }

        vlan_interface : # 3560-af155-c21a Vlan93
            l_interface vlan_interface_name
            l_description description
            l_ip_address ip_address
            no_ip_redirects
            ip_ospf_auth_key
            standby_ip
            standby_timers
            standby_preempt
            l_standby_track standby_track
            { chomp(%item); $return = \%item }
        | # 6509-af155-d5a Vlan102
            l_interface vlan_interface_name
            ### HAAACCKK!!!
            l_description /\*\*\* [a-zA-Z0-9\-_\/ ]+ \*\*\*/
            l_ip_address ip_address
            no_ip_redirects
            no_ip_unreachables
            l_ip_pim_dr_priority ip_pim_dr_priority
            ip_pim_sparse_mode
            ip_pim_snooping
            ip_ospf_digest_key
            l_ospf_priority ospf_priority
            l_standby_delay standby_delay
            standby_ip
            standby_preempt
            { chomp(%item); $return = \%item }
        | # 6509-af155-d5a Vlan105 and others
            l_interface vlan_interface_name
            l_description description
            l_ip_address ip_address
            no_ip_redirects
            ip_pim_sparse_mode
            ip_ospf_digest_key
            l_standby_delay standby_delay
            standby_ip
            standby_preempt
            { chomp(%item); $return = \%item }

 #       vpn_tunnel_interface :
 #           l_interface interface_name
 #           l_description description
 #           bandwidth
 #           l_ip_address ip_address
 #           no_ip_redirects(?)
 #           ip_mtu
 #           ip_pim
 #           ip_nhrp_authentication
 #           ip_nhrp_map(?)
 #           ip_nhrp_map_multicast
 #           ip_nhrp_network_id
 #           ip_nhrp_holdtime
 #           ip_nhrp_nhs
 #           ip_tcp_adjust_mss
 #           no_ip_split_horizon(?)
 #           ip_ospf_network_broadcast
 #           ip_ospf_priority
 #           tunnel_source
 #           tunnel_destination(?)
 #           tunnel_mode(?)
 #           tunnel_key
 #           tunnel_protection
 #           { chomp(%item); $return = \%item }

#        shutdown_port_channel_interface :
#            l_interface interface_name
#            l_sp_access_vlan sp_access_vlan
#            sp_trunk_encap
#            l_sp_trunk_native_vlan sp_trunk_native_vlan
#            l_sp_trunk_allowed_vlan sp_trunk_allowed_vlan(s /,/)
#            sp_mode_trunk
#            "shutdown"
#            l_ch_grp ch_grp l_ch_grp_mode ch_grp_mode
#            span_tree_pf_disable
#            { chomp(%item); $return = \%item }


        # old unused rules
        # for channel groups?
        #l_ch_grp ch_grp l_ch_grp_mode ch_grp_mode

        # rules are made up of productions (below)
        ### BEGIN PRODUCTIONS
        # vlan_num: /\d+/ | /\d+,/ | /\d+-\d+/ | /\d+-\d+,/
        l_interface: "interface"
        interface_name: norm_interface_name | pc_interface_name
        norm_interface_name: /[a-zA-Z0-9\-_\/]+/ 
        pc_interface_name: /Port-channel[0-9]+/
        vlan_interface_name: /Vlan[0-9]+/
        l_description: "description"
        description: /[a-zA-Z0-9\-_\/]+/

        # misc options
        no_ip_address: "no ip address"
        switchport: "switchport"

        # switchport options
        l_sp_access_vlan: "switchport access vlan"
        sp_access_vlan: /\d+/
        #
        l_sp_trunk_native_vlan: "switchport trunk native vlan"
        #sp_trunk_native_vlan: /\d+/ | /\d+,/ | /\d+-\d+/ | /\d+-\d+,/
        sp_trunk_native_vlan: /\d+/
        #
        l_sp_trunk_allowed_vlan: "switchport trunk allowed vlan"
        #sp_trunk_allowed_vlan: /\d+/ | /\d+,/ | /\d+-\d+/ | /\d+-\d+,/
        sp_trunk_allowed_vlan: /\d+-\d+/ | /\d+/
        # 
        l_sp_trunk_encap: "switchport trunk encapsulation"
        sp_trunk_encap: /\w+/
        sp_mode: "switchport mode"
        sp_mode_trunk: "switchport mode trunk"
        sp_mode_access: "switchport mode access"

        # channel group options
        l_ch_grp: "channel-group"
        l_ch_grp_mode: "mode"
        ch_grp: /\d+/
        ch_grp_mode: "on"

        # spanning tree options
        span_tree_pf: span_tree_pf_enable | span_tree_pf_disable 
        span_tree_pf_enable: "spanning-tree portfast"
        span_tree_pf_disable: "spanning-tree portfast disable"
        
        # vlan/vpn tunnel common options
        l_ip_address: "ip address"
        ip_address: /\d+\.\d+\.\d+\.\d+ \d+\.\d+\.\d+\.\d+/
        no_ip_redirects: "no ip redirects"
        no_ip_unreachables: "no ip unreachables"
        l_ip_pim_dr_priority: "ip pim dr-priority"
        ip_pim_dr_priority: /\d+/
        ip_pim_sparse_mode: "ip pim sparse-mode"
        ip_pim_snooping: "ip pim snooping"
        ip_ospf_auth_key: /ip ospf authentication-key [0|7] [0-9A-F]+/
        ip_ospf_digest_key: /ip ospf message-digest-key 1 md5 [0|7] [0-9A-F]+/
        l_ospf_priority: "ip ospf priority"
        ospf_priority: /\d+/
        l_standby_delay: "standby delay"
        standby_delay: /minimum \d+ reload \d+/
        standby_ip: /standby ip \d+\.\d+\.\d+\.\d+/
        standby_timers: /standby timers \d+ \d+/
        standby_preempt: "standby preempt"
        l_standby_track: "standby track"
        standby_track: /[a-zA-Z0-9\/]+ \d+/

        # vpn tunnel options
        bandwidth: /bandwidth \d+/
        ip_mtu: /ip mtu \d+/

EOG
) or die q(ERROR: bad Parse::RecDescent grammar);

    my $self = bless( {
        _parser => $parser, 
    }, $class );
    
    # return this object to the caller
    return $self;
} # sub new

=head2 parse($text_to_be_parsed)

Parse the text block passed in from the caller, and return a hash containing the
key/value pairs generated by the L<Parse::RecDescent> module.  If the parser
did not parse the block, then C<undef> is returned to the caller.

=cut

sub parse {
    my $self = shift;
    my $parse_text = shift;
    my $parser = $self->{_parser};

    return $parser->cfg_block($parse_text);
} # sub parse

=head1 AUTHOR

Brian Manning, C<< <bmanning at qualcomm.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<mflohelp at qualcomm.com>.  I
will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc ISE::CiscoParse::Parser

You can also contact the ISE team at:

    L<mediaflo.ise@qualcomm.com>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Qualcomm Inc., all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of ISE::CiscoParse::Parser
