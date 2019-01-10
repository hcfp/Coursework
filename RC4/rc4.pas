program rc4;
uses
  sysutils, strutils;
type
  myArray = array[0..255] of integer;
  dynamicArray = array of integer;
  dynamicArrayString = array of string;
const
  key = 'qwertyui';
var
  plaintext : string;

function KSA(const key: string): myArray;
var
  i, j, key_length, temp: integer;
  S : myArray;
begin
  key_length := length(key);
  j := 0;
  for i := Low(S) to High(S) do
    S[i] := i;
  for i := Low(S) to High(S) do
  begin
    j := ((j + S[i] + ord(key[i mod key_length + 1])) mod 256);
    temp := S[i];
    S[i] := S[j];
    S[j] := temp;
  end;
  KSA := S;
end;

function PRGA(S : myArray; n : integer) : dynamicArray;
var
  i, j, K, temp, sizeOfArray : integer;
  key : dynamicArray;
begin
  i := 0;
  j := 0;
  K := 0;
  temp := 0;
  sizeOfArray := n - 1;
  SetLength(key, sizeOfArray);
  while n > 0 do
  begin
    n := n - 1;
    i := (i + 1) mod 256;
    j := (j + S[i]) mod 256;
    temp := S[i];
    S[i] := S[j];
    S[j] := temp;
    K := S[(S[i] + S[j]) mod 256];
    key[i-1] := K;
  end;
  PRGA := key;
end;

procedure getPlaintext;
begin
  readln(plaintext);
end;

function encrypt : string;
var
  sizeOfArray, i : integer;
  cipherString : string;
  cipher, keystream: dynamicArray;
  S : myArray;
begin
  S := KSA(key);
  keystream := PRGA(S, length(plaintext));
  sizeOfArray := 0;
  for i := 0 to (length(plaintext) - 1) do
  begin
    sizeOfArray := sizeOfArray + 1;
    SetLength(cipher, sizeOfArray);
    cipher[i] := (keystream[i]) xor (ord(plaintext[i + 1]));
  end;
  cipherString := '';
  for i := 0 to High(cipher) do
    cipherString := cipherString + IntToHex(cipher[I], 2);
  encrypt := cipherString;
end;

function stringToHex(cipherString : string) : dynamicArrayString;
var
  sizeOfArray, i: integer;
  DecryptArrayString : dynamicArrayString;
begin
  sizeOfArray := 0;
  i := 0;
  // Turn the string into an array of hex
  while length(cipherString) > 0 do
  begin
    sizeOfArray := sizeOfArray + 1;
    SetLength(DecryptArrayString, sizeOfArray);
    DecryptArrayString[i] := cipherString[1] + cipherString[2];
    i := i + 1;
    cipherString := rightstr(cipherString, length(cipherString) - 2);
  end;
  stringToHex :=  DecryptArrayString;
end;

function hexToDecimal(DecryptArrayString : dynamicArrayString) : dynamicArray;
var
  sizeOfDecryptArrayInt, i : integer;
  DecryptArrayInt : dynamicArray;
begin
  sizeOfDecryptArrayInt := 0;
  // Hex to decimal
  for i := 0 to high(DecryptArrayString) do
  begin
    sizeOfDecryptArrayInt := sizeOfDecryptArrayInt + 1;
    SetLength(DecryptArrayInt, sizeOfDecryptArrayInt);
    DecryptArrayInt[i] := Hex2Dec(DecryptArrayString[i]);
  end;
  hexToDecimal := DecryptArrayInt;
end;

function decrypt(DecryptArrayInt : dynamicArray) : string;
var
  DecryptedString : string;
  S : myArray;
  keystream, Decrypted : dynamicArray;
  sizeOfArray, i : integer;
begin
  sizeOfArray := 0;
  for i := 0 to high(DecryptArrayInt) do
  begin
    sizeOfArray := sizeOfArray + 1;
    SetLength(Decrypted, sizeOfArray);
    S := KSA(key);
    keystream := PRGA(S, length(plaintext));
    Decrypted[i] := (keystream[i] xor DecryptArrayInt[i]);
  end;
  decryptedString := '';
  // Turn array to string
  for i := 0 to high(Decrypted) do
    decryptedString := decryptedString + chr(Decrypted[i]);
  decrypt := decryptedString;
end;

procedure encryptDecrypt;
var
  cipherString, DecryptedString : string;
  DecryptArrayString : dynamicArrayString;
  DecryptArrayInt : dynamicArray;
begin
  cipherString := encrypt;
  writeln(cipherString);
  DecryptArrayString := stringToHex(cipherString);
  DecryptArrayInt := hexToDecimal(DecryptArrayString);
  DecryptedString := decrypt(DecryptArrayInt);
  writeln(DecryptedString);
end;

begin
  getPlaintext;
  encryptDecrypt;
  readln;
end.