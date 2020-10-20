# Autor: Nicol Castillo
# Pat a Mat jdou proti sobe ve vzdaelnosti length. Vzdy kdyz jsou tesne vedle sebe nebo nad sebou tak si davaji
# kamen, nuzky, papir, jester a spok. Ten kro prohraje se vraci pred startovni caru a musi od zacatku. Pat a Mat
# se nahodne pohybuji vzdy bud o jedna nebo o dva dopraedu.

from random import randint


# length - delka soutezni trasy
# who - jestli se jedna o Pata (1) nebo Mata (2)
# no_where - cislo souradnice kde se nachazi
def print_game(length, who, no_where):
    left = " Start ["
    right = "] Finish"
    player = "P"

    if who == 1:
        player = "M"
        left = "Finish ["
        right = "] Start"

    print(left, end=" ")

    for i in range(length + 1):

        # zakladni vzhled trasy
        if i == no_where:
            print(player, end=" ")
        else:
            print(".", end=" ")

        # hranice leveho ciloveho/startovniho policka
        if i == 0:
            print("]", end=" ")

        # startovaci/cilova cara
        if i == 1 or i == (length - 2):
            print("|", end=" ")

        # hranice leveho ciloveho/startovniho policka
        if i == (length - 1):
            print("[", end=" ")

    print(right)


# funkce pro vykresleni trasy Pata a Mata
# length - delka trasy
# p a m _position udava, kde se Pat a Mat nachazeji
# napr: 10, 2, 5
#   " Start [ . ] . | P . . . . . . | . [ . ] Finish"
#   "Finish [ . ] . | . . . M . . . | . [ . ] Start"
def move(length, p_position, m_position):
    print_game(length, 0, p_position)
    print_game(length, 1, m_position)
    print()


# funkce generuje nahodne cislo v pozadovem intervalu (v pripade, ze bychom chteli, aby hrali jen kamen, nuzky a papir)
# in_rng - maximalni hodnota pro nahodne generovani cisla
def gen_sign(in_rng):
    gen_symbol = randint(1, in_rng)
    return gen_symbol


# funkce prevadi vygenerovane cislo na odpovidajici string
def sign_string(no):
    if no == 1:
        sym_in_str = "SCISSORS"
    elif no == 2:
        sym_in_str = "STONE"
    elif no == 3:
        sym_in_str = "PAPER"
    elif no == 4:
        sym_in_str = "LIZARD"
    else:
        sym_in_str = "SPOCK"

    return sym_in_str


# length - delka trasy
# p a m _position udava, kde se Pat a Mat nachazeji
# output - T/F - true pro vypisovani hry
def game_play(length, p_position, m_position, output):

    # pocitadla
    game_turn = 0
    p_win = 0
    m_win = 0

    # dekud neni vitez
    while p_win == m_win:

        game_turn += 1

        # generujeme co Pat a Mat zahraji
        p_symbol = gen_sign(5)
        m_symbol = gen_sign(5)

        # promenna pro vypis stringu
        px = sign_string(p_symbol)
        mx = sign_string(m_symbol)

        if output:
            print(game_turn, ". round", sep="")
            print("Player Pat raised", px)
            print("Player Mat raised", mx)

        if px == mx:
            if output:
                print()

        # vsechny pripady, kdy vyhraje Pat
        elif ((p_symbol == 1) and (m_symbol == 3 or m_symbol == 4)) or (
                (p_symbol == 2) and ((m_symbol == 1) or (m_symbol == 4))) or (
                (p_symbol == 3) and ((m_symbol == 2) or (m_symbol == 5))) or (
                (p_symbol == 4) and ((m_symbol == 3) or (m_symbol == 5))) or (
                (p_symbol == 5) and ((m_symbol == 1) or (m_symbol == 2))):

            if output:
                print("Player Pat won this fight.")
                print()

            m_position = length

            p_win += 1
            return 1

        # jinak vyhrava Mat
        else:

            m_win += 1

            if output:
                print("Player Mat won this fight.")
                print()

            p_position = 0

            return 2


def rps(length, output):
    # pocita kolik kroku trva jedna hra
    leg_round = 0

    # nastaveni startovnich pozic Pata a Mata
    p_position = 0
    m_position = length

    whom = 0

    if output:
        print("Starting board:")
        move(length, p_position, m_position)

    # dokud neni Pat nebo Mat na viteznem bode cesty
    while (p_position < length) and (m_position > 1):

        leg_round += 1

        p_position += randint(1, 2)
        m_position -= randint(1, 2)

        if output:
            print("Step:", leg_round)
            print("Name: Pat Position:", p_position)
            print("Name: Mat Position:", m_position)
            move(length, p_position, m_position)

        # pokud jsou Pat a Mat vedle sebe nebo jsou teste vedle sebe
        if abs(m_position - p_position) < 2:
            winner_was = game_play(length, p_position, m_position, output)

            if winner_was == 1:             # vyhral Pat
                m_position = length - 1     # Mat musi na zacatek

            elif winner_was == 2:           # vyhral Mat
                p_position = 1              # Pat musi na zacatek

    if p_position > length-1:
        if output:
            # pomocny vypis
            # print("Finishing move is:")
            # move(length, p_position, m_position)

            print("--------------------------")
            print("--------------------------")
            print("Player Pat won this game!")
            print()
            return 1
        else:
            return 1

    if m_position <= 1:
        if output:
            move(length, p_position, m_position)

            print("--------------------------")
            print("--------------------------")
            print("Player Mat won this game!")
            print()
            return 2

        else:
            return 2



def analyze_rps(length, count):

    games_played = 0

    p_winner = 0
    m_winner = 0

    comb_list = [0, 0]

    p_comb_counter = 0
    m_comb_counter = 0

    for i in range(count):

        games_played += 1
        # print("games played : ", games_played, end="")
        # print()

        x = rps(length, False)
        # print("last victor", x, end=" ")
        # print()

        if x == 1:
            p_winner += 1
            p_comb_counter += 1
            if m_comb_counter != 0:
                if comb_list[1] < m_comb_counter:
                    comb_list[1] = m_comb_counter
                m_comb_counter = 0
                # print(comb_list)

        if x == 2:
            m_winner += 1
            m_comb_counter += 1
            if p_comb_counter != 0:
                if comb_list[0] < p_comb_counter:
                    comb_list[0] = p_comb_counter
                p_comb_counter = 0
                # print(comb_list)

    # last check of combo:
    if m_comb_counter != 0:
        if comb_list[1] < m_comb_counter:
            comb_list[1] = m_comb_counter

    if p_comb_counter != 0:
        if comb_list[0] < p_comb_counter:
            comb_list[0] = p_comb_counter

        # print("pat: ", p_winner, end=" ")
        # print()
        # print("mat:", m_winner, end=" ")
        # print()

    if comb_list[0] == comb_list[1]:
        successor = 0
        comber = "Both"

    elif comb_list[0] < comb_list[1]:
        comber = "Mat"
        successor = 1

    else:
        successor = 0
        comber = "Pat"

    print("----- Succesfully played", games_played, "games -----")
    print("Pat won:", p_winner)
    print("Mat won:", m_winner)

    print(comber, "rached combo of:", comb_list[successor])
    # print(comb_list)

    if p_winner > m_winner:
        print("~~~ Pat is the overall victor ! ~~~")
        return

    if p_winner < m_winner:
        print("~~~ Mat is the overall victor ! ~~~")
        return

    print("~~~ Pat and Mat tied ~~~")
