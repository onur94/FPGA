Entity Button_debouncer Is
	Port (
		input  : In     STD_LOGIC;
		clk    : In     STD_LOGIC;
		output : Buffer STD_LOGIC := '0'
	);
End Button_debouncer;

Architecture Behavioral Of Button_debouncer Is
Begin
	Process (input, clk)
		Variable counter : INTEGER Range 0 To 50000000 := 0;
		Variable pressed : BOOLEAN;
	Begin
		If rising_edge(clk) Then
			If input = '1' Then
				pressed := true;
			Else
				output <= '0';
			End If;
			If pressed = true Then
				counter := counter + 1;
				If counter = 2500000 Then
					counter := 0;
					pressed := false;
					If input = '1' Then
						output <= '1';
					Else
						output <= '0';
					End If;
				End If;
			End If;
		End If;
	End Process;
End Behavioral;