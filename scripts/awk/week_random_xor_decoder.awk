BEGIN {
  ASCII_CHARS = \
  "\001\002\003\004\005\006\007\b\t\n\v\f\r\016\017\020\021\022\023\024\025\026\027\030\031\032\033 !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"  
  plain_text= "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
  ciphet_text="EICTDGYIYZKTHNSIRFXYCPFUEOCKRN"
  n = length(ciphet_text)

  for (i = 1; i <= n; i++){
    a = ord(substr(plain_text,i,1))
    b = ord(substr(ciphet_text,i,1))
    key[i] = bxor(a,b)
    printf "%d ", key[i]
  }
  print ""
  key_len=30
}

{
  text_len = length($0)

  for (i=1; i<=text_len; i++){
    a=ord(substr($0,i,1))
    b=key[(i-1)%key_len + 1]
    plain_num=bxor(a,b)
    plain_char=substr(ASCII_CHARS,plain_num+1,1)
    printf "%s", plain_char
  }
  print ""
}


function bxor(a, b,    r, p) {
  r = 0
  p = 1
  while (a || b) {
    if ((a % 2) != (b % 2))
      r += p
    a = int(a / 2)
    b = int(b / 2)
    p *= 2
  }
  return r
}

function ord(c) {
  return index(ASCII_CHARS,c) - 1
}