EUROBONUS

    #!/usr/bin/perl

    #------------------------------------------------------
    # Author: Serhiy Lunak
    # Version 1.0.0
    #
    # License: GNU GENERAL PUBLIC LICENSE Version 2
    # see LICENSE file for more details.
    #
    # Description: This script checks given IP addresses
    # agains given RBLs.
    #------------------------------------------------------

    use warnings;
    use strict;
    use Socket;

    sub verify_ip($);
    sub reverse_ip($);
    sub usage();
    sub trim($);
    sub send_mail($);
    sub send_slack($);

    # Configuration vars
    my $path_to_sendmail = '/usr/sbin/sendmail';
    my $email_to='insert@email.here';
    my $email_from= 'insert@email.here';
    my $email_subject='RBL';

    my $slack_url= 'https://';
    my $slack_channel= '#general';
    my $slack_username= 'RBL';



    # check if all args are present
    if ( !defined $ARGV[0] || !defined $ARGV[1] || !defined $ARGV[2]) {
        usage();
        exit;
    }

    # vars
    my $ip_list     = $ARGV[0];
    my $rbl_list    = $ARGV[1];
    my $action      = $ARGV[2];

    my $output      = '';
    my $detected    = 0;


    ######### Script Start

    open RBL, "<", "$rbl_list" or die "Cannot open file $rbl_list.";
    # read in a line from a file and if there is one continue to process lines until end of file
    while (my $rbl = <RBL>) {
        my @rbl_details = split(';', $rbl);

        my $rbl_name    = $rbl_details[0];
        my $rbl_address = $rbl_details[1];
        my $rbl_url     = trim( $rbl_details[2] );

        # Try to open for reading & if it opens OK
        open IPS, "<", "$ip_list" or die "Cannot open file $ip_list.";
        # read in a line from a file and if there is one continue to process lines until end of file
        while (my $ip = <IPS>) {
            chomp($ip);
            # check if its IP address
            if( verify_ip($ip) ) {
                my $reverse_ip = reverse_ip($ip);
                my $answer = gethostbyname($reverse_ip.'.'.$rbl_address.'.');
                if( defined $answer ){
                    if ($action eq 'email') {
                        $output .= $ip."\t".gethostbyaddr(inet_aton($ip), AF_INET)."\t".$rbl_name."\t".inet_ntoa($answer)."\t".$rbl_address."\t".$rbl_url."\n";
                    } else {
                        print $ip."\t".gethostbyaddr(inet_aton($ip), AF_INET)."\t".$rbl_name."\t".inet_ntoa($answer)."\t".$rbl_address."\t".$rbl_url."\n";
                    }
                    if ($action eq 'slack') {
                      $output .= $ip."\t".gethostbyaddr(inet_aton($ip), AF_INET)."\t".$rbl_name."\t".inet_ntoa($answer)."\t".$rbl_address."\t".$rbl_url."\n";
                    }
                    $detected++;
                }
            }
        }
        close IPS;
    }
    close RBL;


    # sending email
    if( $action eq 'email' ) {
        if ( $detected == 0 ) {
            send_mail( 'All IPs are clear!' );
        } else {
            send_mail( $output );
        }

    }
    # sending to slack
    if( $action eq 'slack' ) {
        if ( $detected == 0 ) {
            send_slack( 'All IPs are clear!' );
        } else {
            send_slack( $output );
        }

    }


    sub verify_ip($) {
        my $ipaddr = shift;
        if( $ipaddr =~ m/^(\d\d?\d?)\.(\d\d?\d?)\.(\d\d?\d?)\.(\d\d?\d?)$/ ) {
            if($1 <= 255 && $2 <= 255 && $3 <= 255 && $4 <= 255) {
                return 1;
            } else {
                return 0;
            }
        } else {
            return 0;
        }
    }

    sub reverse_ip($) {
        my $ipaddr = shift;
        return join( '.', reverse split( /\./, $ipaddr ) );
    }

    sub usage() {
        print "\n";
        print "rbl-checker, version 1.0.0\n";
        print "Author: Serhiy Lunak\n\n";
        print "Usage:\n\n";
        print "Running the script: ~> perl rbl-checker.pl [list-of-ips-to-check.txt] [blacklist.txt] [action]\n\n";
        print "Where arguments:\n";
        print " list-of-ips-to-check.txt: List of IP addresses to check againts RBLs\n";
        print " blacklist.txt: List of known RBLs\n";
        print " action: display, email or slack (for email and slack please modify configuration vars in the script.)\n";
        print "\n";
    }

    sub trim($)
    {
        my $string = shift;
        $string =~ s/^\s+//;
        $string =~ s/\s+$//;
        return $string;
    }

    sub send_mail($) {
        my $email = shift;

        open(MAIL, "|$path_to_sendmail -t");

        ## Mail Header
        print MAIL "To: $email_to\n";
        print MAIL "From: $email_from\n";
        print MAIL "Subject: $email_subject\n\n";
        ## Mail Body
        print MAIL $email;
        close(MAIL);
    }

    sub send_slack($) {
        $output = shift;
        my $command = "curl -X POST --data-urlencode 'payload={\"channel\": \"$slack_channel\", \"username\": \"$slack_username\", \"text\": \"$output\", \"icon_emoji\": \":ghost:\"}' $slack_url";
        print "command: $command \n";
        system ($command);
    }
