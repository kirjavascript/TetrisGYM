/* BPS module for Rom Patcher JS v20180930 - Marc Robledo 2016-2018 - http://www.marcrobledo.com/license */
/* File format specification: https://www.romhacking.net/documents/746/ */
/* Modified to run on node.js for TetrisGYM */

const BPS_MAGIC='BPS1';
const BPS_ACTION_SOURCE_READ=0;
const BPS_ACTION_TARGET_READ=1;
const BPS_ACTION_SOURCE_COPY=2;
const BPS_ACTION_TARGET_COPY=3;


function BPS(){
	this.sourceSize=0;
	this.targetSize=0;
	this.metaData='';
	this.actions=[];
	this.sourceChecksum=0;
	this.targetChecksum=0;
	this.patchChecksum=0;
}
BPS.prototype.toString=function(){
	var s='Source size: '+this.sourceSize;
	s+='\nTarget size: '+this.targetSize;
	s+='\nMetadata: '+this.metaData;
	s+='\n#Actions: '+this.actions.length;
	return s
}
BPS.prototype.validateSource=function(romFile,headerSize){return this.sourceChecksum===crc32(romFile, headerSize)}
BPS.prototype.apply=function(romFile, validate){
	if(validate && !this.validateSource(romFile)){
		throw new Error('error_crc_input');
	}


	tempFile=new MarcFile(this.targetSize);


	//patch
	var sourceRelativeOffset=0;
	var targetRelativeOffset=0;
	for(var i=0; i<this.actions.length; i++){
		var action=this.actions[i];

		if(action.type===BPS_ACTION_SOURCE_READ){
			romFile.copyToFile(tempFile, tempFile.offset, action.length);
			tempFile.skip(action.length);

		}else if(action.type===BPS_ACTION_TARGET_READ){
			tempFile.writeBytes(action.bytes);

		}else if(action.type===BPS_ACTION_SOURCE_COPY){
			sourceRelativeOffset+=action.relativeOffset;
			var actionLength=action.length;
			while(actionLength--){
				tempFile.writeU8(romFile._u8array[sourceRelativeOffset]);
				sourceRelativeOffset++;
			}
		}else if(action.type===BPS_ACTION_TARGET_COPY){
			targetRelativeOffset+=action.relativeOffset;
			var actionLength=action.length;
			while(actionLength--) {
				tempFile.writeU8(tempFile._u8array[targetRelativeOffset]);
				targetRelativeOffset++;
			}
		}
	}

	if(validate && this.targetChecksum!==crc32(tempFile)){
		throw new Error('error_crc_output');
	}

	return tempFile
}



function parseBPSFile(file){
	file.readVLV=BPS_readVLV;

	file.littleEndian=true;
	var patch=new BPS();


	file.seek(4); //skip BPS1

	patch.sourceSize=file.readVLV();
	patch.targetSize=file.readVLV();

	var metaDataLength=file.readVLV();
	if(metaDataLength){
		patch.metaData=file.readString(metaDataLength);
	}


	var endActionsOffset=file.fileSize-12;
	while(file.offset<endActionsOffset){
		var data=file.readVLV();
		var action={type: data & 3, length: (data >> 2)+1};

		if(action.type===BPS_ACTION_TARGET_READ){
			action.bytes=file.readBytes(action.length);

		}else if(action.type===BPS_ACTION_SOURCE_COPY || action.type===BPS_ACTION_TARGET_COPY){
			var relativeOffset=file.readVLV();
			action.relativeOffset=(relativeOffset & 1? -1 : +1) * (relativeOffset >> 1)
		}

		patch.actions.push(action);
	}

	//file.seek(endActionsOffset);
	patch.sourceChecksum=file.readU32();
	patch.targetChecksum=file.readU32();
	patch.patchChecksum=file.readU32();

	if(patch.patchChecksum!==crc32(file, 0, true)){
		throw new Error('error_crc_patch');
	}


	return patch;
}



function BPS_readVLV(){
	var data=0, shift=1;
	while(true){
		var x = this.readU8();
		data += (x & 0x7f) * shift;
		if(x & 0x80)
			break;
		shift <<= 7;
		data += shift;
	}

	this._lastRead=data;
	return data;
}
function BPS_writeVLV(data){
	while(true){
		var x = data & 0x7f;
		data >>= 7;
		if(data === 0){
			this.writeU8(0x80 | x);
			break;
		}
		this.writeU8(x);
		data--;
	}
}
function BPS_getVLVLen(data){
	var len=0;
	while(true){
		var x = data & 0x7f;
		data >>= 7;
		if(data === 0){
			len++;
			break;
		}
		len++;
		data--;
	}
	return len;
}


BPS.prototype.export=function(fileName){
	var patchFileSize=BPS_MAGIC.length;
	patchFileSize+=BPS_getVLVLen(this.sourceSize);
	patchFileSize+=BPS_getVLVLen(this.targetSize);
	patchFileSize+=BPS_getVLVLen(this.metaData.length);
	patchFileSize+=this.metaData.length;
	for(var i=0; i<this.actions.length; i++){
		var action=this.actions[i];
		patchFileSize+=BPS_getVLVLen(((action.length-1)<<2) + action.type);

		if(action.type===BPS_ACTION_TARGET_READ){
			patchFileSize+=action.length;
		}else if(action.type===BPS_ACTION_SOURCE_COPY || action.type===BPS_ACTION_TARGET_COPY){
			patchFileSize+=BPS_getVLVLen((Math.abs(action.relativeOffset)<<1)+(action.relativeOffset<0?1:0));
		}
	}
	patchFileSize+=12;

	var patchFile=new MarcFile(patchFileSize);
	patchFile.fileName=fileName+'.bps';
	patchFile.littleEndian=true;
	patchFile.writeVLV=BPS_writeVLV;

	patchFile.writeString(BPS_MAGIC);
	patchFile.writeVLV(this.sourceSize);
	patchFile.writeVLV(this.targetSize);
	patchFile.writeVLV(this.metaData.length);
	patchFile.writeString(this.metaData, this.metaData.length);

	for(var i=0; i<this.actions.length; i++){
		var action=this.actions[i];
		patchFile.writeVLV(((action.length-1)<<2) + action.type);

		if(action.type===BPS_ACTION_TARGET_READ){
			patchFile.writeBytes(action.bytes);
		}else if(action.type===BPS_ACTION_SOURCE_COPY || action.type===BPS_ACTION_TARGET_COPY){
			patchFile.writeVLV((Math.abs(action.relativeOffset)<<1)+(action.relativeOffset<0?1:0));
		}
	}
	patchFile.writeU32(this.sourceChecksum);
	patchFile.writeU32(this.targetChecksum);
	patchFile.writeU32(this.patchChecksum);

	return patchFile;
}

function BPS_Node(){
	this.offset=0;
	this.next=null;
};
BPS_Node.prototype.delete=function(){
	if(this.next)
		delete this.next;
}
function createBPSFromFiles(original, modified, deltaMode){
	var patch=new BPS();
	patch.sourceSize=original.fileSize;
	patch.targetSize=modified.fileSize;

	if(deltaMode){
		patch.actions=createBPSFromFilesDelta(original, modified);
	}else{
		patch.actions=createBPSFromFilesLinear(original, modified);
	}

	patch.sourceChecksum=crc32(original);
	patch.targetChecksum=crc32(modified);
	patch.patchChecksum=crc32(patch.export(), 0, true);
	return patch;
}


/* delta implementation from https://github.com/chiya/beat/blob/master/nall/beat/linear.hpp */
function createBPSFromFilesLinear(original, modified){
	var patchActions=[];

	/* references to match original beat code */
	var sourceData=original._u8array;
	var targetData=modified._u8array;
	var sourceSize=original.fileSize;
	var targetSize=modified.fileSize;
	var Granularity=1;



	var targetRelativeOffset=0;
	var outputOffset=0;
	var targetReadLength=0;

	function targetReadFlush(){
		if(targetReadLength){
			//encode(TargetRead | ((targetReadLength - 1) << 2));
			var action={type:BPS_ACTION_TARGET_READ, length:targetReadLength, bytes:[]};
			patchActions.push(action);
			var offset = outputOffset - targetReadLength;
			while(targetReadLength){
				//write(targetData[offset++]);
				action.bytes.push(targetData[offset++]);
				targetReadLength--;
			}
		}
	};

	while(outputOffset < targetSize) {
		var sourceLength = 0;
		for(var n = 0; outputOffset + n < Math.min(sourceSize, targetSize); n++) {
			if(sourceData[outputOffset + n] != targetData[outputOffset + n]) break;
			sourceLength++;
		}

		var rleLength = 0;
		for(var n = 1; outputOffset + n < targetSize; n++) {
			if(targetData[outputOffset] != targetData[outputOffset + n]) break;
			rleLength++;
		}

		if(rleLength >= 4) {
			//write byte to repeat
			targetReadLength++;
			outputOffset++;
			targetReadFlush();

			//copy starting from repetition byte
			//encode(TargetCopy | ((rleLength - 1) << 2));
			var relativeOffset = (outputOffset - 1) - targetRelativeOffset;
			//encode(relativeOffset << 1);
			patchActions.push({type:BPS_ACTION_TARGET_COPY, length:rleLength, relativeOffset:relativeOffset});
			outputOffset += rleLength;
			targetRelativeOffset = outputOffset - 1;
		} else if(sourceLength >= 4) {
			targetReadFlush();
			//encode(SourceRead | ((sourceLength - 1) << 2));
			patchActions.push({type:BPS_ACTION_SOURCE_READ, length:sourceLength});
			outputOffset += sourceLength;
		} else {
			targetReadLength += Granularity;
			outputOffset += Granularity;
		}
	}

	targetReadFlush();



	return patchActions;
}

/* delta implementation from https://github.com/chiya/beat/blob/master/nall/beat/delta.hpp */
function createBPSFromFilesDelta(original, modified){
	var patchActions=[];


	/* references to match original beat code */
	var sourceData=original._u8array;
	var targetData=modified._u8array;
	var sourceSize=original.fileSize;
	var targetSize=modified.fileSize;
	var Granularity=1;



	var sourceRelativeOffset=0;
	var targetRelativeOffset=0;
	var outputOffset=0;



	var sourceTree=new Array(65536);
	var targetTree=new Array(65536);
	for(var n=0; n<65536; n++){
		sourceTree[n]=null;
		targetTree[n]=null;
	}



	//source tree creation
	for(var offset=0; offset<sourceSize; offset++) {
		var symbol = sourceData[offset + 0];
		//sourceChecksum = crc32_adjust(sourceChecksum, symbol);
		if(offset < sourceSize - 1)
			symbol |= sourceData[offset + 1] << 8;
		var node=new BPS_Node();
		node.offset=offset;
		node.next=sourceTree[symbol];
		sourceTree[symbol] = node;
	}

	var targetReadLength=0;

	function targetReadFlush(){
		if(targetReadLength) {
			//encode(TargetRead | ((targetReadLength - 1) << 2));
			var action={type:BPS_ACTION_TARGET_READ, length:targetReadLength, bytes:[]};
			patchActions.push(action);
			var offset = outputOffset - targetReadLength;
			while(targetReadLength){
				//write(targetData[offset++]);
				action.bytes.push(targetData[offset++]);
				targetReadLength--;
			}
		}
	};

	while(outputOffset<modified.fileSize){
		var maxLength = 0, maxOffset = 0, mode = BPS_ACTION_TARGET_READ;

		var symbol = targetData[outputOffset + 0];
		if(outputOffset < targetSize - 1) symbol |= targetData[outputOffset + 1] << 8;

		{ //source read
			var length = 0, offset = outputOffset;
			while(offset < sourceSize && offset < targetSize && sourceData[offset] == targetData[offset]) {
				length++;
				offset++;
			}
			if(length > maxLength) maxLength = length, mode = BPS_ACTION_SOURCE_READ;
		}

		{ //source copy
			var node = sourceTree[symbol];
			while(node) {
				var length = 0, x = node.offset, y = outputOffset;
				while(x < sourceSize && y < targetSize && sourceData[x++] == targetData[y++]) length++;
				if(length > maxLength) maxLength = length, maxOffset = node.offset, mode = BPS_ACTION_SOURCE_COPY;
				node = node.next;
			}
		}

		{ //target copy
			var node = targetTree[symbol];
			while(node) {
				var length = 0, x = node.offset, y = outputOffset;
				while(y < targetSize && targetData[x++] == targetData[y++]) length++;
				if(length > maxLength) maxLength = length, maxOffset = node.offset, mode = BPS_ACTION_TARGET_COPY;
				node = node.next;
			}

			//target tree append
			node = new BPS_Node();
			node.offset = outputOffset;
			node.next = targetTree[symbol];
			targetTree[symbol] = node;
		}

		{ //target read
			if(maxLength < 4) {
				maxLength = Math.min(Granularity, targetSize - outputOffset);
				mode = BPS_ACTION_TARGET_READ;
			}
		}

		if(mode != BPS_ACTION_TARGET_READ) targetReadFlush();

		switch(mode) {
			case BPS_ACTION_SOURCE_READ:
				//encode(BPS_ACTION_SOURCE_READ | ((maxLength - 1) << 2));
				patchActions.push({type:BPS_ACTION_SOURCE_READ, length:maxLength});
				break;
			case BPS_ACTION_TARGET_READ:
				//delay write to group sequential TargetRead commands into one
				targetReadLength += maxLength;
				break;
			case BPS_ACTION_SOURCE_COPY:
			case BPS_ACTION_TARGET_COPY:
				//encode(mode | ((maxLength - 1) << 2));
				var relativeOffset;
				if(mode == BPS_ACTION_SOURCE_COPY) {
					relativeOffset = maxOffset - sourceRelativeOffset;
					sourceRelativeOffset = maxOffset + maxLength;
				} else {
					relativeOffset = maxOffset - targetRelativeOffset;
					targetRelativeOffset = maxOffset + maxLength;
				}
				//encode((relativeOffset < 0) | (abs(relativeOffset) << 1));
				patchActions.push({type:mode, length:maxLength, relativeOffset:relativeOffset});
				break;
		}

		outputOffset += maxLength;
	}

	targetReadFlush();


	return patchActions;
}

// crc32.js
/* Rom Patcher JS - CRC32/MD5/SHA-1/checksums calculators v20210815 - Marc Robledo 2016-2021 - http://www.marcrobledo.com/license */

function padZeroes(intVal, nBytes){
	var hexString=intVal.toString(16);
	while(hexString.length<nBytes*2)
		hexString='0'+hexString;
	return hexString
}


/* SHA-1 using WebCryptoAPI */
function _sha1_promise(hash){
	var bytes=new Uint8Array(hash);
	var hexString='';
	for(var i=0;i<bytes.length;i++)
		hexString+=padZeroes(bytes[i], 1);
	el('sha1').innerHTML=hexString;
}
function sha1(marcFile){
	window.crypto.subtle.digest('SHA-1', marcFile._u8array.buffer)
		.then(_sha1_promise)
		.catch(function(error){
			el('sha1').innerHTML='Error';
		})
	;
}



/* MD5 - from Joseph's Myers - http://www.myersdaily.org/joseph/javascript/md5.js */
const HEX_CHR='0123456789abcdef'.split('');
function _add32(a,b){return (a+b)&0xffffffff}
function _md5cycle(x,k){var a=x[0],b=x[1],c=x[2],d=x[3];a=ff(a,b,c,d,k[0],7,-680876936);d=ff(d,a,b,c,k[1],12,-389564586);c=ff(c,d,a,b,k[2],17,606105819);b=ff(b,c,d,a,k[3],22,-1044525330);a=ff(a,b,c,d,k[4],7,-176418897);d=ff(d,a,b,c,k[5],12,1200080426);c=ff(c,d,a,b,k[6],17,-1473231341);b=ff(b,c,d,a,k[7],22,-45705983);a=ff(a,b,c,d,k[8],7,1770035416);d=ff(d,a,b,c,k[9],12,-1958414417);c=ff(c,d,a,b,k[10],17,-42063);b=ff(b,c,d,a,k[11],22,-1990404162);a=ff(a,b,c,d,k[12],7,1804603682);d=ff(d,a,b,c,k[13],12,-40341101);c=ff(c,d,a,b,k[14],17,-1502002290);b=ff(b,c,d,a,k[15],22,1236535329);a=gg(a,b,c,d,k[1],5,-165796510);d=gg(d,a,b,c,k[6],9,-1069501632);c=gg(c,d,a,b,k[11],14,643717713);b=gg(b,c,d,a,k[0],20,-373897302);a=gg(a,b,c,d,k[5],5,-701558691);d=gg(d,a,b,c,k[10],9,38016083);c=gg(c,d,a,b,k[15],14,-660478335);b=gg(b,c,d,a,k[4],20,-405537848);a=gg(a,b,c,d,k[9],5,568446438);d=gg(d,a,b,c,k[14],9,-1019803690);c=gg(c,d,a,b,k[3],14,-187363961);b=gg(b,c,d,a,k[8],20,1163531501);a=gg(a,b,c,d,k[13],5,-1444681467);d=gg(d,a,b,c,k[2],9,-51403784);c=gg(c,d,a,b,k[7],14,1735328473);b=gg(b,c,d,a,k[12],20,-1926607734);a=hh(a,b,c,d,k[5],4,-378558);d=hh(d,a,b,c,k[8],11,-2022574463);c=hh(c,d,a,b,k[11],16,1839030562);b=hh(b,c,d,a,k[14],23,-35309556);a=hh(a,b,c,d,k[1],4,-1530992060);d=hh(d,a,b,c,k[4],11,1272893353);c=hh(c,d,a,b,k[7],16,-155497632);b=hh(b,c,d,a,k[10],23,-1094730640);a=hh(a,b,c,d,k[13],4,681279174);d=hh(d,a,b,c,k[0],11,-358537222);c=hh(c,d,a,b,k[3],16,-722521979);b=hh(b,c,d,a,k[6],23,76029189);a=hh(a,b,c,d,k[9],4,-640364487);d=hh(d,a,b,c,k[12],11,-421815835);c=hh(c,d,a,b,k[15],16,530742520);b=hh(b,c,d,a,k[2],23,-995338651);a=ii(a,b,c,d,k[0],6,-198630844);d=ii(d,a,b,c,k[7],10,1126891415);c=ii(c,d,a,b,k[14],15,-1416354905);b=ii(b,c,d,a,k[5],21,-57434055);a=ii(a,b,c,d,k[12],6,1700485571);d=ii(d,a,b,c,k[3],10,-1894986606);c=ii(c,d,a,b,k[10],15,-1051523);b=ii(b,c,d,a,k[1],21,-2054922799);a=ii(a,b,c,d,k[8],6,1873313359);d=ii(d,a,b,c,k[15],10,-30611744);c=ii(c,d,a,b,k[6],15,-1560198380);b=ii(b,c,d,a,k[13],21,1309151649);a=ii(a,b,c,d,k[4],6,-145523070);d=ii(d,a,b,c,k[11],10,-1120210379);c=ii(c,d,a,b,k[2],15,718787259);b=ii(b,c,d,a,k[9],21,-343485551);x[0]=_add32(a,x[0]);x[1]=_add32(b,x[1]);x[2]=_add32(c,x[2]);x[3]=_add32(d,x[3])}
function _md5blk(d){var md5blks=[],i;for(i=0;i<64;i+=4)md5blks[i>>2]=d[i]+(d[i+1]<<8)+(d[i+2]<<16)+(d[i+3]<<24);return md5blks}
function _cmn(q,a,b,x,s,t){a=_add32(_add32(a,q),_add32(x,t));return _add32((a<<s)|(a>>>(32-s)),b)}
function ff(a,b,c,d,x,s,t){return _cmn((b&c)|((~b)&d),a,b,x,s,t)}
function gg(a,b,c,d,x,s,t){return _cmn((b&d)|(c&(~d)),a,b,x,s,t)}
function hh(a,b,c,d,x,s,t){return _cmn(b^c^d,a,b,x,s,t)}
function ii(a,b,c,d,x,s,t){return _cmn(c^(b|(~d)),a,b,x,s,t)}
function md5(marcFile, headerSize){
	var data=headerSize? new Uint8Array(marcFile._u8array.buffer, headerSize):marcFile._u8array;

	var n=data.length,state=[1732584193,-271733879,-1732584194,271733878],i;
	for(i=64;i<=data.length;i+=64)
		_md5cycle(state,_md5blk(data.slice(i-64,i)));
	data=data.slice(i-64);
	var tail=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
	for(i=0;i<data.length;i++)
		tail[i>>2]|=data[i]<<((i%4)<<3);
	tail[i>>2]|=0x80<<((i%4)<<3);
	if(i>55){
		_md5cycle(state,tail);
		for(i=0;i<16;i++)tail[i]=0;
	}
	tail[14]=n*8;
	tail[15]=Math.floor(n/536870912) >>> 0; //if file is bigger than 512Mb*8, value is bigger than 32 bits, so it needs two words to store its length
	_md5cycle(state,tail);

	for(var i=0;i<state.length;i++){
		var s='',j=0;
		for(;j<4;j++)
			s+=HEX_CHR[(state[i]>>(j*8+4))&0x0f]+HEX_CHR[(state[i]>>(j*8))&0x0f];
		state[i]=s;
	}
	return state.join('')
}



/* CRC32 - from Alex - https://stackoverflow.com/a/18639999 */
const CRC32_TABLE=(function(){
	var c,crcTable=[];
	for(var n=0;n<256;n++){
		c=n;
		for(var k=0;k<8;k++)
			c=((c&1)?(0xedb88320^(c>>>1)):(c>>>1));
		crcTable[n]=c;
	}
	return crcTable;
}());
function crc32(marcFile, headerSize, ignoreLast4Bytes){
	var data=headerSize? new Uint8Array(marcFile._u8array.buffer, headerSize):marcFile._u8array;

	var crc=0^(-1);

	var len=ignoreLast4Bytes?data.length-4:data.length;
	for(var i=0;i<len;i++)
		crc=(crc>>>8)^CRC32_TABLE[(crc^data[i])&0xff];

	return ((crc^(-1))>>>0);
}



/* Adler-32 - https://en.wikipedia.org/wiki/Adler-32#Example_implementation */
const ADLER32_MOD=0xfff1;
function adler32(marcFile, offset, len){
	var a=1, b=0;

	for(var i=0; i<len; i++){
		a=(a+marcFile._u8array[i+offset])%ADLER32_MOD;
		b=(b+a)%ADLER32_MOD;
	}

	return ((b<<16) | a)>>>0;
}




/* CRC16/CCITT-FALSE */
function crc16(marcFile, offset, len){
	var crc=0xffff;

	offset=offset? offset : 0;
	len=len && len>0? len : marcFile.fileSize;

	for(var i=0; i<len; i++){
		crc ^= marcFile._u8array[offset++] << 8;
        for (j=0; j<8; ++j) {
            crc = (crc & 0x8000) >>> 0 ? (crc << 1) ^ 0x1021 : crc << 1;
        }
	}

	return crc & 0xffff;
}
/* MODDED VERSION OF MarcFile.js v20230202 - Marc Robledo 2014-2023 - http://www.marcrobledo.com/license */

function MarcFile(source, onLoad){
	this.littleEndian=false;
	this.offset=0;
	this._lastRead=null;
    const num = typeof source === 'number';
    const fs = require('fs');
    const ab = num ? new ArrayBuffer(source) : fs.readFileSync(source).buffer;
    this._u8array=new Uint8Array(ab);
    this._dataView=new DataView(ab);
    this.fileName=num ? 'file.bin' : source;
    this.fileType='application/octet-stream';
    this.fileSize=num ? source : ab.byteLength;

    if(onLoad)
        onLoad.call();
}
MarcFile.IS_MACHINE_LITTLE_ENDIAN=(function(){	/* https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/DataView#Endianness */
	var buffer=new ArrayBuffer(2);
	new DataView(buffer).setInt16(0, 256, true /* littleEndian */);
	// Int16Array uses the platform's endianness.
	return new Int16Array(buffer)[0] === 256;
})();


MarcFile.prototype.seek=function(offset){
	this.offset=offset;
}
MarcFile.prototype.skip=function(nBytes){
	this.offset+=nBytes;
}
MarcFile.prototype.isEOF=function(){
	return !(this.offset<this.fileSize)
}

MarcFile.prototype.slice=function(offset, len){
	len=len || (this.fileSize-offset);

	var newFile;

	if(typeof this._u8array.buffer.slice!=='undefined'){
		newFile=new MarcFile(0);
		newFile.fileSize=len;
		newFile._u8array=new Uint8Array(this._u8array.buffer.slice(offset, offset+len));
	}else{
		newFile=new MarcFile(len);
		this.copyToFile(newFile, offset, len, 0);
	}
	newFile.fileName=this.fileName;
	newFile.fileType=this.fileType;
	newFile.littleEndian=this.littleEndian;
	return newFile;
}


MarcFile.prototype.copyToFile=function(target, offsetSource, len, offsetTarget){
	if(typeof offsetTarget==='undefined')
		offsetTarget=offsetSource;

	len=len || (this.fileSize-offsetSource);

	for(var i=0; i<len; i++){
		target._u8array[offsetTarget+i]=this._u8array[offsetSource+i];
	}
}


MarcFile.prototype.save=function(){
	var blob;
	try{
		blob=new Blob([this._u8array],{type:this.fileType});
	}catch(e){
		//old browser, use BlobBuilder
		window.BlobBuilder=window.BlobBuilder || window.WebKitBlobBuilder || window.MozBlobBuilder || window.MSBlobBuilder;
		if(e.name==='InvalidStateError' && window.BlobBuilder){
			var bb=new BlobBuilder();
			bb.append(this._u8array.buffer);
			blob=bb.getBlob(this.fileType);
		}else{
			throw new Error('Incompatible Browser');
			return false;
		}
	}
	saveAs(blob,this.fileName);
}


MarcFile.prototype.getExtension=function(){
	var ext=this.fileName? this.fileName.toLowerCase().match(/\.(\w+)$/) : '';

	return ext? ext[1] : '';
}


MarcFile.prototype.readU8=function(){
	this._lastRead=this._u8array[this.offset];

	this.offset++;
	return this._lastRead
}
MarcFile.prototype.readU16=function(){
	if(this.littleEndian)
		this._lastRead=this._u8array[this.offset] + (this._u8array[this.offset+1] << 8);
	else
		this._lastRead=(this._u8array[this.offset] << 8) + this._u8array[this.offset+1];

	this.offset+=2;
	return this._lastRead >>> 0
}
MarcFile.prototype.readU24=function(){
	if(this.littleEndian)
		this._lastRead=this._u8array[this.offset] + (this._u8array[this.offset+1] << 8) + (this._u8array[this.offset+2] << 16);
	else
		this._lastRead=(this._u8array[this.offset] << 16) + (this._u8array[this.offset+1] << 8) + this._u8array[this.offset+2];

	this.offset+=3;
	return this._lastRead >>> 0
}
MarcFile.prototype.readU32=function(){
	if(this.littleEndian)
		this._lastRead=this._u8array[this.offset] + (this._u8array[this.offset+1] << 8) + (this._u8array[this.offset+2] << 16) + (this._u8array[this.offset+3] << 24);
	else
		this._lastRead=(this._u8array[this.offset] << 24) + (this._u8array[this.offset+1] << 16) + (this._u8array[this.offset+2] << 8) + this._u8array[this.offset+3];

	this.offset+=4;
	return this._lastRead >>> 0
}



MarcFile.prototype.readBytes=function(len){
	this._lastRead=new Array(len);
	for(var i=0; i<len; i++){
		this._lastRead[i]=this._u8array[this.offset+i];
	}

	this.offset+=len;
	return this._lastRead
}

MarcFile.prototype.readString=function(len){
	this._lastRead='';
	for(var i=0;i<len && (this.offset+i)<this.fileSize && this._u8array[this.offset+i]>0;i++)
		this._lastRead=this._lastRead+String.fromCharCode(this._u8array[this.offset+i]);

	this.offset+=len;
	return this._lastRead
}

MarcFile.prototype.writeU8=function(u8){
	this._u8array[this.offset]=u8;

	this.offset++;
}
MarcFile.prototype.writeU16=function(u16){
	if(this.littleEndian){
		this._u8array[this.offset]=u16 & 0xff;
		this._u8array[this.offset+1]=u16 >> 8;
	}else{
		this._u8array[this.offset]=u16 >> 8;
		this._u8array[this.offset+1]=u16 & 0xff;
	}

	this.offset+=2;
}
MarcFile.prototype.writeU24=function(u24){
	if(this.littleEndian){
		this._u8array[this.offset]=u24 & 0x0000ff;
		this._u8array[this.offset+1]=(u24 & 0x00ff00) >> 8;
		this._u8array[this.offset+2]=(u24 & 0xff0000) >> 16;
	}else{
		this._u8array[this.offset]=(u24 & 0xff0000) >> 16;
		this._u8array[this.offset+1]=(u24 & 0x00ff00) >> 8;
		this._u8array[this.offset+2]=u24 & 0x0000ff;
	}

	this.offset+=3;
}
MarcFile.prototype.writeU32=function(u32){
	if(this.littleEndian){
		this._u8array[this.offset]=u32 & 0x000000ff;
		this._u8array[this.offset+1]=(u32 & 0x0000ff00) >> 8;
		this._u8array[this.offset+2]=(u32 & 0x00ff0000) >> 16;
		this._u8array[this.offset+3]=(u32 & 0xff000000) >> 24;
	}else{
		this._u8array[this.offset]=(u32 & 0xff000000) >> 24;
		this._u8array[this.offset+1]=(u32 & 0x00ff0000) >> 16;
		this._u8array[this.offset+2]=(u32 & 0x0000ff00) >> 8;
		this._u8array[this.offset+3]=u32 & 0x000000ff;
	}

	this.offset+=4;
}


MarcFile.prototype.writeBytes=function(a){
	for(var i=0;i<a.length;i++)
		this._u8array[this.offset+i]=a[i]

	this.offset+=a.length;
}

MarcFile.prototype.writeString=function(str,len){
	len=len || str.length;
	for(var i=0;i<str.length && i<len;i++)
		this._u8array[this.offset+i]=str.charCodeAt(i);

	for(;i<len;i++)
		this._u8array[this.offset+i]=0x00;

	this.offset+=len;
}

module.exports = { MarcFile, createBPSFromFiles, parseBPSFile };
