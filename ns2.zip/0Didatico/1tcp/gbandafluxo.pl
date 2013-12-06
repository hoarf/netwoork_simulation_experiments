#!/usr/bin/perl

# Dá o número de bits enviados no link cada décimo de segundo
# O valor é relativo a determinado fluxo em determinado link 
# uso: "perl gbandafluxo.pl N F"
# N=número do nodo a medir
# F=número do fluxo a medir


open (ARQ, "out.tr") || die;

$tempo = 0;
$banda = 0;
$totalbytes = 0;

while(<ARQ>) {
	chop;
	  $_ =~ s/^[d|-|v|+].*//;
 	 next if not $_;
 
	@inf = split (/[\s]+/, $_);

	if ($inf[0] eq "r" && $inf[3] == $ARGV[0] && $inf[7] == $ARGV[1]) {
		$banda = $banda + ($inf[5] * 8);
	}

	if ($inf[1] >= $tempo + 0.1) {
	# como mede cada 0,1 segundos divide por 100000 para ter em Mbps
		print $tempo." ".($banda/100000)."\n";
		$tempo = $tempo + 0.1;
		$banda = 0;
	}
}
	

close ARQ;
		