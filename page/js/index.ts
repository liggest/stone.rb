
let socket:WebSocket = undefined

interface Message {
    type: "greeting" | "code",
    text:string
}

function connect() {
    socket = new WebSocket(`ws://${location.host}/ws`)
    init()
    return socket
}

function reconnect() {
    console.log("Reconnecting...");
    setTimeout(() => {
        if(socket.readyState!==socket.OPEN) {
            reconnect()
        }
    }, 3000);
    return connect();
}

function greetMsg(text) {
    socket.send(JSON.stringify({ type:"greeting", text:text } as Message))
}

function codeMsg(text="") {
    text||=code.value
    socket.send(JSON.stringify({ type:"code", text:text } as Message))
}

function init() {
    socket.onopen = (_) => {
        console.log("Open!");
        greetMsg("yeah!!")

        code.dispatchEvent(new InputEvent("input",{ data:code.textContent }))
    }
    
    socket.onmessage = (event) => {
        let data=JSON.parse(event.data)
        console.log("From Server",data)
        fillResult(data)
    }
    
    socket.onclose = (_) => {
        socket.close()
        console.log("Connection closed...")
        reconnect()
    }    
}

let code:HTMLTextAreaElement = undefined
const initCode='print("Hell World")'

let result:HTMLDivElement = undefined

addEventListener("load",(event) => {
    connect()
    code=document.getElementById("code") as HTMLTextAreaElement
    result=document.getElementById("result") as HTMLDivElement

    code.textContent+=initCode

    code.addEventListener("input",(event:InputEvent) => {
        // console.log(event)
        // console.log(event.data)
        // console.log(code.selectionStart)
        // console.log(code.selectionEnd)
        codeMsg()
    })

    code.addEventListener("paste", (event) => {
        // event.clipboardData.getData()
        codeMsg()
    })
})

interface Token {
    name: "name" | "str" | "num" | "EOF" | "lineNo" | "space",
    str: string,
    lineNo?: number
}

interface ResultError {
    name:"error",
    str: string,
}

function newLine() {
    let line = document.createElement("div")
    line.className = "line"
    return line
}

function newToken(name:(Token | ResultError)["name"],text:string) {
    let token = document.createElement("span")
    token.textContent=text
    token.classList.add("token",name)
    return token
}

function addLine(line:HTMLDivElement,lineNo:number=undefined) {
    if(lineNo) line.insertBefore(newToken("lineNo",lineNo.toString()),line.firstChild)

    result.appendChild(line)
    // result.appendChild(document.createElement("br"))
}

function errorLine(error:ResultError) {
    let line=newLine()
    line.appendChild(newToken("error",`    Error: ${error.str}`))
    line.classList.add(error.name)
    if(result.lastElementChild.classList.contains(error.name)) {
        result.replaceChild(line,result.lastElementChild)
    } else {
        addLine(line)
    }
}

function fillResult(results: Array<Token> | ResultError) {
    if(!(results instanceof Array)) {
        errorLine(results)
        return
    }
    let lineNo=0
    let line=newLine()
    let rawCode=code.value
    let pos=0
    result.innerHTML=""
    for (const token of results) {
        lineNo=token.lineNo
        let pre=rawCode.indexOf(token.str,pos)
        // console.log(token.str,rawCode.substring(pos+pre))
        
        // while (pos+pre<rawCode.length && !rawCode.startsWith(token.str,pos+pre)) {
        //     pre++
        // }
        if(pre>=0)
        {
            line.appendChild(newToken("space"," ".repeat(pre-pos)))
            pos=pre
        }
        if(token.str==="\n") {
            addLine(line,lineNo)
            line=newLine()
        } else {
            line.appendChild(newToken(token.name,token.str))
        }
        pos+=token.str.length
    }
    if(line.childNodes.length) {
        addLine(line,lineNo)
    }
}

