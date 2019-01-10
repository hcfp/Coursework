program passcheck;
uses regexpr, crt;
var
	re : TRegExpr;
	password : string;
	count : integer;
	meetsLength : boolean;

begin
	repeat
		meetsLength := false;
		re := TRegExpr.create;
		count := 0;
		writeln('Enter password to test');
		readln(password);
		if length(password) < 8 then
		begin
			writeln('Password below 8 characters');
		end
		else
		begin
			writeln('Password meet character limit');
			meetsLength := true;
			count := count + 1;
		end;
		re.expression := '\d+';
		if re.exec(password) then
		begin
			writeln('Contains digits');
			count := count + 1;
		end
		else
			writeln('No digits');
		
		re.expression := '[a-z]+';
		if re.exec(password) then
		begin
			writeln('Contains lowercase letters');
			count := count + 1;
		end
		else
			writeln('No lowercase letter');
		
		re.expression := '[A-Z]+';
		if re.exec(password) then
		begin
			count := count + 1;
			writeln('Contains uppercase letters');
		end
		else
			writeln('No uppercase letters');
		re.free;
		
		re.expression := '[~`!@#\$%\^&*\(\)\+=_\-\{\}\[\]\\|:;\?\/<>,\.]+';
		if re.exec(password) then
		begin
			writeln('Contains special characters');
			count := count + 1;
		end
		else
			writeln('No special characters');

		if (not(meetsLength)) or (count < 4) then
		begin
			textcolor(red);
			writeln('The password does not meet the minimum requirements');
			textcolor(white);
		end
		else
		begin
			textcolor(lightgreen);
			writeln('The password meets the minimum requirements');
			textcolor(white);
		end;
	until password = 'q'
end.