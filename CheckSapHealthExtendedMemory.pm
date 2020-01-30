package MyExtended;
our @ISA = qw(Classes::SAP::Netweaver::Item);
use strict;

sub init {
  my $self = shift;
  if ($self->mode =~ /sap::extended::memory/) {
    my $ping = $self->session->function_lookup("SAPTUNE_GET_SUMMARY_STATISTIC"); #Zavolá funkčný modul
    my $fc = $ping->create_function_call;
    $fc->invoke(); #Vytvorí spojenie
    my $used; #Premenné, do ktorých ukladám jednotlivé riadky (rows a hodnoty)
    my $attached;
    my $total;
    my $allocated;
    my $used_percentage;
    foreach my $row ($fc->EXTENDED_MEMORY_USAGE) { #Namapujem do premenných konkretné riadky
        $attached = $row->{'ATTACHED'};
        $allocated = $row->{'ALLOCATED'};
        $total = $row->{'TOTAL'};
        $used = $row->{'USED'};
        $used_percentage = $row->{'ALLOCATED'}/$total*100; #Percentá
        #$quota = $row->{'QUOTA_DIA'}; max. size EM for dialog WPs - nepotrebné na výpis
        $used = $row->{'USED'};


        my $metric = lc 'num_'.$used;
        $self->set_thresholds(metric => $metric, #Nastavím threshold
            warning => '70', critical => '80',
        );
        $self->add_message(
            $self->check_thresholds(metric => $metric, value => $used_percentage), #Funkcia, ktorá kontroluje zadaný threshold s aktuálnou value -> vracia value
            sprintf "SAP Extended memory usage %.2f%% (total: %s, currently used: %s)", $used_percentage,$total.' MB',$allocated.' MB');
    }
    #my @types = $fc->EXTENDED_MEMORY_USAGE; -> Volanie exportu
    # NEPOTREBNÉ

    #printf "Total: %s\n", ($total.' MB');
    #printf "Attached: %.2f%% - %s\n", ($attached/$total*100), $attached.' MB';
    #printf "Allocated: %.2f%% - %s\n", ($allocated/$total*100), $allocated.' MB';
    #printf "Used: %.2f%% - %s\n", ($used/$total*100), $used.' MB';
    #printf "------------------------------------------------------- \n";
    # Percentá a normálna hodnota
    #printf "Used: %s - %.2f%%\n", $used, ($used/$total*100 );


  }
}
