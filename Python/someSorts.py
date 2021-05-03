# basically bubble sort
def sortInts(given_list):
  for b in range(len(given_list)-1):
    for t in range(len(given_list)-1):
      if given_list[t] > given_list[t+1]:
        given_list[t+1], given_list[t] = given_list[t], given_list[t+1]

# merge lists by ord value
def twine(g_int_l, g_char_l):
  index_i = 0
  index_c = 0
  ret_list = []

  for i in range(len(g_char_l)+len(g_int_l)):
    if index_i == len(g_int_l):
      for rest_of_char in range(len(g_char_l)-index_c):
        ret_list.append(chr(g_char_l[index_c]))
        index_c += 1
      return ret_list

    if index_c == len(g_char_l):
      ret_list = ret_list + g_int_l[index_i:]
      return ret_list

    #print(index_i, g_int_l[index_i], "vs", index_c, g_char_l[index_c])

    if g_char_l[index_c] < g_int_l[index_i]:
      ret_list.append(chr(g_char_l[index_c]))
      index_c += 1
      continue
    ret_list.append(g_int_l[index_i])
    index_i += 1

# priority default 0 sorts ints before chars
def sortList(given_list, priority=0):
  listInts = []
  listChars = []
  listTwined = []

  for item in given_list:
    if type(item) == int:
      listInts.append(item)
      continue
    item = ord(item)
    listChars.append(item)
  
  sortInts(listInts)
  sortInts(listChars)

  if priority == 2:
    listTwined = twine(listInts, listChars)

  for c in range(len(listChars)):
    listChars[c] = chr(listChars[c])

  if priority == 1:
    listInts, listChars = listChars, listInts

  given_list = listInts + listChars

  if priority == 2:
    given_list = listTwined

  print(given_list)

somelist = [1, 'k', 98, 'c', 133, 96, 97, 3, 44, 'a', 10, 'b', 3, 'a', -33]
print(somelist)
sortList(somelist)      # sort int, cort char, merge int+char
sortList(somelist,1)    # sort int, cort char, merge char+int
sortList(somelist,2)    # sort int, cort char, merge int and char by ord value
# print(somelist.sort()) - can sort only same type
