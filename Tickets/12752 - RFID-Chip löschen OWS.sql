DECLARE @chipcode VARCHAR(16);
DECLARE @cursor_chipdeleted CURSOR;
DECLARE @delsign VARCHAR(4);

@chipcode = (SELECT Chipcode FROM __input);
OPEN @cursor_chipdeleted AS SELECT * FROM OpTeile WHERE Code LIKE @chipcode+'%';
@delsign = '';

TRY
	WHILE FETCH @cursor_chipdeleted DO
		@delsign = @delsign + '*';
	END WHILE;
	
	UPDATE OpTeile SET Code = @chipcode + @delsign WHERE Code = @chipcode;
FINALLY
	CLOSE @cursor_chipdeleted;
END TRY;