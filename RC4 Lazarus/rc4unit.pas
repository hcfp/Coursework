unit RC4Unit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  StrUtils;

type

  { TForm1 }

  TForm1 = class(TForm)
    ButtonEncrypt: TButton;
    ButtonDecrypt: TButton;
    EditOutputPlaintext: TEdit;
    EditOutputCiphertext: TEdit;
    EditPlaintext: TEdit;
    EditCiphertext: TEdit;
    Label1: TLabel;
    Label3: TLabel;
    procedure ButtonDecryptClick(Sender: TObject);
    procedure ButtonEncryptClick(Sender: TObject);
  private

  public

  end;

  myArray = array[0..255] of integer;
  dynamicArray = array of integer;
  dynamicArrayString = array of string;

const
  initialkey = 'key';

var
  Form1: TForm1;
  plaintext, key: string;

implementation

{$R *.lfm}

{ TForm1 }

{procedure initialiseKey;
var
  i : integer;
  iv : string;
begin
  randomize;
  iv := '';
  for i := 0 to 2 do
    iv := iv + chr(random(26) + 65);
  key := initialKey;
  key := key + iv;
end;}

function KSA(const key: string): myArray;
var
  i, j, key_length, temp: integer;
  S : myArray;
begin
  //come to brazil!!!
  key_length := length(key);
  j := 0;
  //initialises the array S to the identity permutation
  for i := Low(S) to High(S) do
    S[i] := i;
  for i := Low(S) to High(S) do
  begin
    //processes S in 256 iterations similar to scramble bytes and mixes in bytes of the key
    j := ((j + S[i] + ord(key[i mod key_length + 1])) mod 256);
    temp := S[i];
    S[i] := S[j];
    S[j] := temp;
  end;
  KSA := S;
end;

function PRGA(S: myArray; n: integer): dynamicArray;
var
  i, j, K, temp, sizeOfArray: integer;
  key: dynamicArray;
begin
  i := 0;
  j := 0;
  K := 0;
  temp := 0;
  //was n-1 which caused a crash
  //n is the size of the inputted array
  sizeOfArray := n;
  //habib bad programmer lol
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
    key[i - 1] := K;               //if key was a certain length it would end
  end;                             //up trying to access key[0] which is an
  PRGA := key;                     //invalid value. FIXED
end;

procedure setPlaintext;
begin
  plaintext := Form1.EditPlaintext.Text;
end;

function encrypt: string;
var
  sizeOfArray, i: integer;
  cipherString: string;
  cipher, keystream: dynamicArray;
  S: myArray;
begin
  //schedules the key to be used in the PRGA based on the Initialkey
  S := KSA(key);
  keystream := PRGA(S, length(plaintext));
  sizeOfArray := 0;
  //XOR each element of the keystream width the plaintext to form an array of integers
  for i := 0 to (length(plaintext) - 1) do
  begin
    sizeOfArray := sizeOfArray + 1;
    SetLength(cipher, sizeOfArray);
    cipher[i] := (keystream[i]) xor (ord(plaintext[i + 1]));
  end;
  //converts the array of integers to an array of string representing hexadecimal values
  cipherString := '';
  for i := 0 to High(cipher) do
    cipherString := cipherString + IntToHex(cipher[i], 2);
  encrypt := cipherString;
end;

function stringToHex(cipherString: string): dynamicArrayString;
var
  sizeOfArray, i: integer;
  DecryptArrayString: dynamicArrayString;
begin
  //During decryption, the inputted string has to be converted to hexadecimal to revert
  //the changes made to the orignal output of the XOR
  sizeOfArray := 0;
  i := 0;
  // here the string is converted to an array of hexadecimal values
  while length(cipherString) > 0 do
  begin
    sizeOfArray := sizeOfArray + 1;
    SetLength(DecryptArrayString, sizeOfArray);
    DecryptArrayString[i] := cipherString[1] + cipherString[2];
    i := i + 1;
    cipherString := rightstr(cipherString, length(cipherString) - 2);
  end;
  stringToHex := DecryptArrayString;
end;

function hexToDecimal(DecryptArrayString: dynamicArrayString): dynamicArray;
var
  sizeOfDecryptArrayInt, i: integer;
  DecryptArrayInt: dynamicArray;
begin
  //Revert the change from decimal to hex during encryption
  sizeOfDecryptArrayInt := 0;
  for i := 0 to high(DecryptArrayString) do
  begin
    sizeOfDecryptArrayInt := sizeOfDecryptArrayInt + 1;
    SetLength(DecryptArrayInt, sizeOfDecryptArrayInt);
    DecryptArrayInt[i] := Hex2Dec(DecryptArrayString[i]);
  end;
  hexToDecimal := DecryptArrayInt;
end;

function decrypt(DecryptArrayInt: dynamicArray) : string;
var
  DecryptedString: string;
  S: myArray;
  keystream, Decrypted: dynamicArray;
  sizeOfArray, i: integer;
begin
  //Since RC4 is a stream cipher based on XOR, the
  //decryption is the same as the encryption
  sizeOfArray := 0;
  S := KSA(key);
  keystream := PRGA(S, length(DecryptArrayInt));
  for i := 0 to high(DecryptArrayInt) do
  begin
    sizeOfArray := sizeOfArray + 1;
    SetLength(Decrypted, sizeOfArray);
    Decrypted[i] := (keystream[i] xor DecryptArrayInt[i]);
  end;
  decryptedString := '';
  // Turns array of integers into the plaintext string
  for i := 0 to high(Decrypted) do
    decryptedString := decryptedString + chr(Decrypted[i]);
  decrypt := decryptedString;
end;

procedure TForm1.ButtonEncryptClick(Sender: TObject);
var
  cipherString : string;
begin
  key := initialKey;
  setPlaintext;
  cipherString := encrypt;
  Form1.EditOutputCiphertext.Caption := cipherString;
end;

procedure TForm1.ButtonDecryptClick(Sender: TObject);
var
  DecryptArrayString: dynamicArrayString;
  DecryptArrayInt: dynamicArray;
  DecryptedString : string;
begin
  key := initialKey;
  //The inputted string is made into an array of hex values
  DecryptArrayString := stringToHex(EditCiphertext.text);
  // This is then converted to an array of integers suitable for XOR
  DecryptArrayInt := hexToDecimal(DecryptArrayString);
  //XOR'd with keystream to produce a plaintext string
  DecryptedString := decrypt(DecryptArrayInt);
  Form1.EditOutputPlaintext.text := DecryptedString;
end;

end.