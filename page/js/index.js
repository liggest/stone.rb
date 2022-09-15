let socket = undefined;
function connect() {
    socket = new WebSocket(`ws://${location.host}/ws`);
    init();
    return socket;
}
function reconnect() {
    console.log("Reconnecting...");
    setTimeout(() => {
        if (socket.readyState !== socket.OPEN) {
            reconnect();
        }
    }, 3000);
    return connect();
}
function greetMsg(text) {
    socket.send(JSON.stringify({ type: "greeting", text: text }));
}
function codeMsg(text = "") {
    text || (text = code.value);
    socket.send(JSON.stringify({ type: "code", text: text }));
}
function init() {
    socket.onopen = (_) => {
        console.log("Open!");
        greetMsg("yeah!!");
        code.dispatchEvent(new InputEvent("input", { data: code.textContent }));
    };
    socket.onmessage = (event) => {
        let data = JSON.parse(event.data);
        console.log("From Server", data);
        fillResult(data);
    };
    socket.onclose = (_) => {
        socket.close();
        console.log("Connection closed...");
        reconnect();
    };
}
let code = undefined;
const initCode = 'print("Hell World")';
let result = undefined;
addEventListener("load", (event) => {
    connect();
    code = document.getElementById("code");
    result = document.getElementById("result");
    code.textContent += initCode;
    code.addEventListener("input", (event) => {
        // console.log(event)
        // console.log(event.data)
        // console.log(code.selectionStart)
        // console.log(code.selectionEnd)
        codeMsg();
    });
    code.addEventListener("paste", (event) => {
        // event.clipboardData.getData()
        codeMsg();
    });
});
function newLine() {
    let line = document.createElement("div");
    line.className = "line";
    return line;
}
function newToken(name, text) {
    let token = document.createElement("span");
    token.textContent = text;
    token.classList.add("token", name);
    return token;
}
function addLine(line, lineNo = undefined) {
    if (lineNo)
        line.insertBefore(newToken("lineNo", lineNo.toString()), line.firstChild);
    result.appendChild(line);
    // result.appendChild(document.createElement("br"))
}
function errorLine(error) {
    let line = newLine();
    line.appendChild(newToken("error", `    Error: ${error.str}`));
    line.classList.add(error.name);
    if (result.lastElementChild.classList.contains(error.name)) {
        result.replaceChild(line, result.lastElementChild);
    }
    else {
        addLine(line);
    }
}
function fillResult(results) {
    if (!(results instanceof Array)) {
        errorLine(results);
        return;
    }
    let lineNo = 0;
    let line = newLine();
    let rawCode = code.value;
    let pos = 0;
    result.innerHTML = "";
    for (const token of results) {
        lineNo = token.lineNo;
        let pre = rawCode.indexOf(token.str, pos);
        // console.log(token.str,rawCode.substring(pos+pre))
        // while (pos+pre<rawCode.length && !rawCode.startsWith(token.str,pos+pre)) {
        //     pre++
        // }
        if (pre >= 0) {
            line.appendChild(newToken("space", " ".repeat(pre - pos)));
            pos = pre;
        }
        if (token.str === "\n") {
            addLine(line, lineNo);
            line = newLine();
        }
        else {
            line.appendChild(newToken(token.name, token.str));
        }
        pos += token.str.length;
    }
    if (line.childNodes.length) {
        addLine(line, lineNo);
    }
}
