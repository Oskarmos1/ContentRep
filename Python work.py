watchingValue = 5
myList = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32]
currentView = myList[0:10]
print(myList)
while True:
    print("-----------------------------")
    x = input()
    if x == "w":
        watchingValue +=1
    elif x == "s":
        if watchingValue != 5:
            watchingValue -=1
    for i in range(10):
        print(myList[watchingValue - (i-4)])
    
