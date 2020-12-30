unit GS.Asserts;

interface

uses sysUtils, Classes;

procedure AssertAssigned(aObject : TObject);
procedure AssertNotEmpty(aString : String);

implementation

procedure AssertAssigned(aObject : TObject);
begin
  Assert(Assigned(aObject));
end;

procedure AssertNotEmpty(aString : String);
begin
  Assert(Length(Trim(aString))>0);
end;


end.