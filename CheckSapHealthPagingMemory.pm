package MyPaging;
our @ISA = qw(Classes::SAP::Netweaver::Item);
use strict;

sub init {

    my $self = shift;
    if ($self->mode =~ /sap::paging::memory/) {
      my $ping = $self->session->function_lookup("SAPTUNE_GET_SUMMARY_STATISTIC"); #Zavolá funkčný modul
      my $fc = $ping->create_function_call;
      $fc->invoke(); #Vytvorí spojenie
      my $celkom;
      my $aktualne;
      my $aktualneProcenta;
   foreach my $row ($fc->PAGING_AREA) {
      $celkom = $row->{'AREA_SIZE'};
      $aktualne = $row->{'CURR_USED'};
      $aktualneProcenta = $row->{'CURR_USED'}/$celkom*100;

      my $metric = lc 'num_'.$aktualne;
      $self->set_thresholds(metric => $metric, #Nastavím threshold
        warning => '70', critical => '80',
      );

      $self->add_message(
          $self->check_thresholds(metric => $metric, value => $aktualneProcenta), #Funkcia, ktorá kontroluje zadaný threshold s aktuálnou value -> vracia value
          sprintf "SAP paging memory usage %.2f%% (total: %.2f MB, currently used: %.2f MB)", $aktualneProcenta, $celkom/1024, $aktualne/1024);

      }
    }
  }
