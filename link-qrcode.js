var qrcode = require('qrcode-terminal');

var fs = require('fs');
fs.readFile('sebs.js', 'utf8', function (err, data) {
  if (err) throw err;
	node = JSON.parse(data);
     
	console.log('-----------------安卓 v2rayNG 链接 / link for v2rayNG on Android-----------------')
    console.log(android(node).toString())
    
    qrcode.generate(android(node).toString(), {small: true},function (qrcode) {
		console.log('-----------------安卓 v2rayNG 二维码 / qrcode for v2rayNG on Android------------------')
		console.log(qrcode);
	});
    
    console.log('-----------------iOS 小火箭链接 / link for shadowrocket on iOS--------------------')
    console.log(ios(node).toString())
    
    qrcode.generate(ios(node).toString(), {small: true},function (qrcode) {
		console.log('-----------------iOS 小火箭二维码 / qrcode for shadowrocket on iOS------------------')
		console.log(qrcode);
	});
	
	console.log('-----------------默认情况下，执行 "docker exec -i -t v2ray node link-qrcode.js" 可查看此信息--------------------')
	console.log('-----------------Run "docker exec -i -t v2ray node link-qrcode.js" to display this information by default--------------------')
});

function ios(node) {
    !node.method ? node.method = 'chacha20-poly1305' : ''
    let v2rayBase = '' + node.method + ':' + node.id + '@' + node.add + ':' + node.port
    let remarks = ''
    // let obfsParam = ''
    let path = ''
    let obfs = ''
    let tls = ''
    !node.ps ? remarks = 'remarks=oneSubscribe' : remarks = `remarks=${node.ps}`
    !node.path ? '' : path = `&path=${node.path}`
    node.net == 'ws' ? obfs = `&obfs=websocket` : ''
    node.net == 'h2' ? obfs = `&obfs=http` : ''
    node.tls == 'tls' ? tls = `&tls=1` : ''
    let query = remarks + path + obfs + tls
    let baseV2ray = Buffer.from(v2rayBase).toString('base64')
    let server = Buffer.from('vmess://' + baseV2ray + '?' + query)
    return server
}

function android(node) {
    node.v = "2"
    // node.path = node.path.replace(/\//, '')
    delete node.method
    let baseV2ray = Buffer.from(JSON.stringify(node)).toString('base64')
    let server = Buffer.from('vmess://' + baseV2ray)
    return server
}

