

import sys, re ; 

first = False;
for line in sys.stdin.readlines(): #{
#	line = line.replace('<sme>','');
#	line = line.replace('←sme→','');
	if line.strip(' \t')[0] == '#' or 'LIST BOS' in line or 'LIST EOS' in line: #{
		sys.stdout.write(line);
		continue;
	#}
	if line.strip() == '': #{
		oper = '';
	#}
	row = line.split(' ');
	if 'SELECT' in row[0]: #{
		oper = 'SELECT';
		first = True;
	elif 'REMOVE' in row[0]: #{
		oper = 'REMOVE';
		first = True;
	elif 'LIST' in row[0]: #{
		oper = 'LIST';
		first = True;
	elif 'MAP' in row[0]: #{
		oper = 'MAP';
		first = True;
	elif 'IFF' in row[0]: #{
		oper = 'IFF';
		first = True;
	elif 'SUBSTITUTE' in row[0]: #{
		oper = 'SUBSTITUTE';
		first = True;
	elif 'SET' in row[0]: #{
		oper = 'SET';
		first = True;
	#}


	print('-', oper,first,'|||', line, file=sys.stderr);

	tokens = line.replace('(', ' ( ').replace(')',' ) ');
	tokens = re.sub('  *', ' ', tokens);
	tokens = tokens.split(' ');

	print(tokens, file=sys.stderr);

	outline = '';
	if oper == 'LIST': #{
		par = 0;
		ntoken = 0;
		for token in tokens: #{
			if token == '(': par = par + 1;
			if token == ')': par = par - 1;

			if par == 1: #{
				outline = outline + token.lower();			
			elif token == 'LIST' or ntoken == 1: #{
				outline = outline + token;
			elif '"' in token: #{
				outline = outline + token;
			elif '@' in token: #{
				outline = outline + token;
			else: #{
				token = token.replace('Ind','Indic');
				outline = outline + token.lower();
			#}
			outline = outline + ' ';
			ntoken = ntoken + 1;
		#}
	elif oper == 'SET': #{
		par = 0;
		ntoken = 0;
		for token in tokens: #{
			if token == '(': par = par + 1;
			if token == ')': par = par - 1;

			if par == 1: #{
				outline = outline + token.lower();			
			elif token == 'LIST' or ntoken == 1: #{
				outline = outline + token;
			elif '"' in token: #{
				outline = outline + token;
			elif '@' in token: #{
				outline = outline + token;
			else: #{
				outline = outline + token;
			#}
			outline = outline + ' ';
			ntoken = ntoken + 1;
		#}
	elif oper == 'SELECT' or oper == 'REMOVE' or oper == 'IFF':
		#- SELECT True ||| SELECT ("albmi") (0 ("almmái")) ;
		# ['SELECT', '(', '"albmi"', ')', '(', '0', '(', '"almmái"', ')', ')', ';\n']
		# + SELECT True ||| SELECT:KillCom ( Pl Loc ) IF ( 0 ( sg com ) ) ;

		seen_par = False;
		par = 0;
		ntoken = 0;
		first_block = True;
		seen_position = False;
		inside = False;
		total_par = 0;
		for token in tokens: #{
			if token == '(': total_par = total_par + 1;
		#}
		for token in tokens: #{
			if token == '(': 
				par = par + 1;
				seen_par = True;
			if token == ')': par = par - 1;
			if token == ')' or (not seen_par and ntoken == 2): first_block = False;

			if token.strip('C*- ').isnumeric() or token == 'NOT' or token == 'NEGATE' or token == 'OR': #{
				inside = True;	
				par = 0;
			#}

			if ntoken == 1: #{
				outline = outline + token;
			elif par == 1 and first_block and token[0] != '"' and token[0] != '@': #{
				outline = outline + token.lower();
			elif inside == True and par == 1 and token[0] != '"' and token[0] != '@': #{
				outline = outline + token.lower();
			else: #{
				outline = outline + token;
			#}
			outline = outline + ' ';
			ntoken = ntoken + 1;
		#}
	elif oper == 'SUBSTITUTE': #{
		#SUBSTITUTE:PlcSur5 (Prop Plc) (Prop Sur) TARGET (Prop Plc Gen) IF (1 ("lusa") OR ("luhtte") OR ("geahčai") OR ("geahčen"));
		par = 0;
		inside = False;
		ntoken = 0;
		first_block = True;
		
		for token in tokens: #{
			if token == '(':  par = par + 1;
			if token == ')':  
				par = par - 1 ;
				inside = False;
	
			if token == 'IF': #{
				first_block = False;
			#}

			if token.strip('C*- ').isnumeric() or token == 'NOT' or token == 'NEGATE' or token == 'OR': #{
				inside = True;	
				par = 0;
			#}

			if ntoken == 1: #{
				outline = outline + token;
			elif par == 1 and first_block and token[0] != '"' and token[0] != '@': #{
				outline = outline + token.lower();
			elif inside == True and par == 1 and token[0] != '"' and token[0] != '@': #{
				outline = outline + token.lower();
			else: #{
				outline = outline + token;
			#}
			outline = outline + ' ';
			ntoken = ntoken + 1;
		#}

	elif oper == 'MAP': #{
		# MAP:veahkki (@<ADVL) TARGET Inf IF (-1 ("veahkki" Acc) LINK *-1 NOT-AUX-V + TRANS-V BARRIER NOT-NPMOD)(NEGATE 0 ("leat")) ;
		# MAP:compInf (@COMP-CS<) TARGET Inf ((*-1 ("go" CS) BARRIER NOT-ADV LINK -1 Inf) OR (*-1 ("go" CS) BARRIER NOT-ADV LINK *-1 Comp LINK *-1 Inf))(NEGATE *1 VFIN BARRIER NOT-ADV-PCLE)(NEGATE 0 AUX + VFIN LINK *1 PrfPrc OR (Actio Ess)) ;

		# MAP:compInf (@COMP-CS←) TARGET Inf ((*-1 ("go" CS) BARRIER NOT-ADV LINK -1 Inf) OR (*-1 ("go" CS) BARRIER NOT-ADV LINK *-1 Comp LINK *-1 Inf)) (NEGATE *1 VFIN BARRIER NOT-ADV-PCLE) (NEGATE 0 AUX + VFIN LINK *1 PrfPrc OR (Actio Ess)) ;
		# MAP:compEss (@COMP-CS←) TARGET (N Ess) (-1 ("go" cs) LINK -1 Nom LINK -1 Comp LINK *-1 (n ess) BARRIER S-BOUNDARY) ;

		par = 0;
		ntoken = 0;
		first_block = True;
		seen_position = False;
		inside = False;
		seen_target = False;
		max_par = 0;
		for token in tokens: #{
			if token == '(': par = par + 1;
			if token == ')': par = par - 1;
			if par > max_par: max_par = par;	
		#}
		par = 0;
		for token in tokens: #{
			if token == '(': 
				par = par + 1;

			if token == ')': 
				if seen_target: first_block = False;
				inside = False;
				par = par - 1;

			if token == 'TARGET': #{
				seen_target = True;
			#}

			if token.strip('C*- ').isnumeric() or token == 'NOT' or token == 'NEGATE' or token == 'OR': #{
				seen_position = True;
				inside = True;
				par = 0;
				first_block = False;
			#} 

			print('***', par, inside, token, file=sys.stderr);

			if ntoken == 1: #{
				outline = outline + token;
			elif par == 1 and first_block and seen_position == False and token[0] != '"' and token[0] != '@': #{
				outline = outline + token.lower();
#			elif par > 1 and par == max_par and not first_block and token[0] != '"' and token[0] != '@': #{
			elif inside == True and par == 1 and token[0] != '"' and token[0] != '@': #{
				outline = outline + token.lower();
			else: #{
				outline = outline + token;
			#}
			outline = outline + ' ';
			ntoken = ntoken + 1;
		#}
#
#	elif oper == 'IFF': #{
#		# IFF:miiIndef ("mii" Indef) IF ((-1 ("vaikko")) OR (1 ("beare")))(NOT *0 (V Pl1) BARRIER SV-BOUNDARY) ;
#		
#		outline = '#';
#	#}


	outline = outline.strip(' ');
	outline = outline.replace('>', '→').replace('<', '←').replace('/', '_').replace('( ', '(').replace(' )',')');
	print('+', oper,first,'|||', outline, file=sys.stderr);
	if outline != '': #{
		sys.stdout.write(outline);
	else: #{
		sys.stdout.write(line);
	#}	
	if first == True and oper != '': #{
		first = False;
	#}
#}
