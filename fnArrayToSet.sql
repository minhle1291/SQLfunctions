SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'TF' AND name = 'fnArrayToSet')
BEGIN
    EXEC (
		'CREATE FUNCTION dbo.fnArrayToSet (
			@Placeholder INT
		)
		RETURNS @Set TABLE (
			Placeholder INT
		)
		AS
		BEGIN
			INSERT INTO @Set SELECT 1
			RETURN
		END'
	)
END
GO

ALTER FUNCTION [dbo].[fnArrayToSet]
(
    @InputString VARCHAR(MAX),
	@SearchChar CHAR
)
RETURNS @Set TABLE (
    ArrayPosition INT NOT NULL,
	ExtractedText VARCHAR(MAX) NULL
)
AS

/*
	SELECT * FROM fnArrayToSet('Hello world!', ' ')
*/

BEGIN
    IF @InputString IS NULL
    RETURN
    
    DECLARE @SearchPosition INT = 0,
			@ArrayPosition INT = 0,
			@LastSearchPosition INT

    WHILE 1 <> 2
    BEGIN
        SET @LastSearchPosition = @SearchPosition
        SET @SearchPosition = CHARINDEX(@SearchChar, @InputString, @SearchPosition + 1)
        SET @ArrayPosition += 1

        IF @SearchPosition = 0
        BEGIN
            INSERT INTO @Set(ArrayPosition, ExtractedText)
            VALUES (@ArrayPosition, SUBSTRING(@InputString, @LastSearchPosition + 1, DATALENGTH(@InputString)))
            BREAK
        END
        ELSE
        BEGIN
			INSERT INTO @Set(ArrayPosition, ExtractedText)
            VALUES (@ArrayPosition, SUBSTRING(@InputString, @LastSearchPosition + 1, @SearchPosition - @LastSearchPosition - 1))
        END
    END
    RETURN
END