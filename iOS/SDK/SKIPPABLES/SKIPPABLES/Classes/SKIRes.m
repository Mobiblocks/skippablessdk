//
//  SKIRes.m
//  SKIPPABLES
//
//  Created by Daniel on 2/27/18.
//  Copyright © 2018 Mobiblocks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define SKI_VOLUME_BASE64 @"iVBORw0KGgoAAAANSUhEUgAAAFoAAABaCAYAAAA4qEECAAAAAXNSR0IArs4c6QAA"\
"AAlwSFlzAAALEwAACxMBAJqcGAAAAVlpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAA"\
"ADx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IlhN"\
"UCBDb3JlIDUuNC4wIj4KICAgPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3"\
"LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICAgICAgPHJkZjpE"\
"ZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6dGlmZj0i"\
"aHR0cDovL25zLmFkb2JlLmNvbS90aWZmLzEuMC8iPgogICAgICAgICA8dGlmZjpP"\
"cmllbnRhdGlvbj4xPC90aWZmOk9yaWVudGF0aW9uPgogICAgICA8L3JkZjpEZXNj"\
"cmlwdGlvbj4KICAgPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KTMInWQAADstJREFU"\
"eAHtmgmsXVUVhlsBQabKJGCBllIkDDIVgdpiC4UoDqAJJhBCEKmGgBCjgkiagiCg"\
"AaOCIEVsGMRIQhQFJ4aKUKQ4IAgVC3SgICAog4CMov93zv5f1zvcc+9955773n14"\
"V/Kfvdbaw1n73+vus895b8yYvvQZ6DPQZ2DIDIwdco/h70CMjpPyvymE14c/lDfv"\
"HU1w2Qxb1Zf1G3Z/Lwf6FrFB1q4m7C9MFTYWnhEWJKjIst1Zjt2XNhlg8Z0AO0r/"\
"ofC4AJnGY9LPEt4mIG6fW/1rSwYiydPV+h7B5JLdrwr/Cb650pE+0TkPbV0jyfuo"\
"x4MCJEPsa0k36a8k+36VOwtIn+ych6bXSPI0tXxAMMlksgl2aR+EHy8g7Ol1SIyl"\
"jvF6Zow4MbaLViSbbGf5uWkmPDQ7lbhY6LX9SuLAnQZZtT+Tgbz3CZcJkwUyNi6A"\
"zDcIfZB18qLjK/fzfddKOveoYwHHrN5xeJ0NwEIzuRnCfGFSsluRrGYDUkeycD9I"\
"3UL4tDBeuEH4qfBvgXrEi5tbo+RqgiB5aZpEPFEwqWZ4NdVfpBLpJPPc92SN43u+"\
"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"\
"AAAASUVORK5CYII="

#define SKI_MUTE_BASE64 @"iVBORw0KGgoAAAANSUhEUgAAAFoAAABaCAYAAAA4qEECAAAAAXNSR0IArs4c6QAA"\
"AAlwSFlzAAALEwAACxMBAJqcGAAAAVlpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAA"\
"ADx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IlhN"\
"UCBDb3JlIDUuNC4wIj4KICAgPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3"\
"LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICAgICAgPHJkZjpE"\
"ZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6dGlmZj0i"\
"aHR0cDovL25zLmFkb2JlLmNvbS90aWZmLzEuMC8iPgogICAgICAgICA8dGlmZjpP"\
"cmllbnRhdGlvbj4xPC90aWZmOk9yaWVudGF0aW9uPgogICAgICA8L3JkZjpEZXNj"\
"cmlwdGlvbj4KICAgPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KTMInWQAACNFJREFU"\
"eAHtm8mr3WQYxuusqFiHRRfWFlvcCCoUBKnSUl27UsRFvbVWNyJUigMWxbGOiBtB"\
"UW9vrxvxH1BEdONcRMGh2hbFLlQEtQ5oW1v1+Z3kuf2aJifJOTk5yT154ck3T7+8"\
"+fLlDgsWdNYR6Ah0BEoTOKZ0i/obMEfPk/C/eAr/1j+V+TuiAWetMK88q13t+U2e"\
"6LGigdceJ10lXSadI+2V3oqloOft9nLSnRUkwM23A1yo+CvSjxIwrR8U3yKdImGu"\
"H6W6ay6BEPLlqv2ZZLh49z/SoSDvPsWxDnTEodA1hHyFWuyWgAzYg3Hc0A/E6Z0K"\
"L5KwDnbEoe81hLxSNXdJhownG7BD5wH8NgljT++sD4EQMttFHmTDtpc/FffNS7Ox"\
"1gQvADTw2C62ScslPDa8AUoeZbTBTo2CZl/HDdpHODx5WjpfKgI5pDruNYRzyYyP"\
"c5KGjCdvlYp6cnIx9uxkfqPSx49hNt4S8Fwg48mGPM4bP1IUdS8MyFiVkN1n1HND"\
"r3V6tIH4xcd2sSyGXvcNr/121LXAEPJqrXJWmhjI3NU6QCch48lLJbaPKsZvxcuw"\
"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"\
"Th6ECsoAAAAASUVORK5CYII="

#define SKI_PAUSE_BASE64 @"iVBORw0KGgoAAAANSUhEUgAAAFoAAABaCAYAAAA4qEECAAAAAXNSR0IArs4c6QAA"\
"AAlwSFlzAAALEwAACxMBAJqcGAAAAVlpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAA"\
"ADx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IlhN"\
"UCBDb3JlIDUuNC4wIj4KICAgPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3"\
"LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICAgICAgPHJkZjpE"\
"ZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6dGlmZj0i"\
"aHR0cDovL25zLmFkb2JlLmNvbS90aWZmLzEuMC8iPgogICAgICAgICA8dGlmZjpP"\
"cmllbnRhdGlvbj4xPC90aWZmOk9yaWVudGF0aW9uPgogICAgICA8L3JkZjpEZXNj"\
"cmlwdGlvbj4KICAgPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KTMInWQAAAstJREFU"\
"eAHtnF2O0zAUhcufmOEB2BAbYAuzAd7YzmwAdgAb4J21ABISCIbhnrZXqpJJarvO"\
"URR9lm7TxvY9119O0r7Uux0NAhCAAAQgAAEIQAACEIAABCAAAQhsh8CjhZaivI87"\
"5L6PHP8K80ivx3qkJ93Vtx6ATxdZkq9kzGnOc+975+vigNOiVaAc8SbiXcSPCLms"\
"1ml3Med1xKeIDxGZN96OWvbdRM/biO8RT0ajzp9Q3S8jbiO+RCiH6lhle3as6n0c"\
"dftdGh+P+ebAZZ/GXqqn+apdLddy+HTh69ML5w+nq1C1n4fD7nccE8Tx1OigOUPH"\
"/4lz1xHfRqOnT+TYXzGkZV1y7/OIrD3XMq1Y0dNSUEn6fMYp/znQc/lq5uZYabas"\
"Ky921j5XV3XfIkmrq5ie0NVV0zLL96wddLpseRILK6wd9MLL96UHtIk1oAG9J8CX"\
"ockIfBmaQG9Ghme06VKuHTTPaJMReEabQG9GZu2PDkBvhoBpITga0CYCJhkcDeg9"\
"AX5Hm4zA72gT6M3I8Iw2XUpAA9pEwCSDowFtImCSwdGANhEwyeBoQJsImGRwNKBN"\
"BEwyOBrQJgImGRwNaBMBkwyOBrSJgEkGRwPaRMAkg6MBbSJgksHRgDYRMMngaECb"\
"CJhkcDSgTQRMMjga0CYCJhkcDWgTAZMMjga0iYBJBkcD2kTAJNOyP1xJaflvqr8x"\
"WFtRzv3pR2OH/dpgULXVbFmZY6XZ0jRfe+dl7S05Juf0Bp3AXhwVtTNiS8u6XlVM"\
"1l6maleHQ/VrambtuZbqRA9NyOQP9bWcS1d9jcnaK1SbwLZ8DyiPwH2OUJtzWfZp"\
"w1g1bZ2ZuzruTxS+5Cawql1Nn1fdWsDOLagkX8mYOY1hX+98o2fjULD1s267HsXK"\
"raXOkl6P2116eZfEWxoEIAABCEAAAhCAAAQgAAEIQAACEIDAkMB/I0tdcDCtzHwA"\
"AAAASUVORK5CYII="

#define SKI_PLAY_BASE64 @"iVBORw0KGgoAAAANSUhEUgAAAFoAAABaCAYAAAA4qEECAAAAAXNSR0IArs4c6QAA"\
"AAlwSFlzAAALEwAACxMBAJqcGAAAAVlpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAA"\
"ADx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IlhN"\
"UCBDb3JlIDUuNC4wIj4KICAgPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3"\
"LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICAgICAgPHJkZjpE"\
"ZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6dGlmZj0i"\
"aHR0cDovL25zLmFkb2JlLmNvbS90aWZmLzEuMC8iPgogICAgICAgICA8dGlmZjpP"\
"cmllbnRhdGlvbj4xPC90aWZmOk9yaWVudGF0aW9uPgogICAgICA8L3JkZjpEZXNj"\
"cmlwdGlvbj4KICAgPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KTMInWQAABgpJREFU"\
"eAHtnUuIHFUUhuMLY9RFDGIQwozLqCBuREWFSIwLURDBrYOgC/GZvUE37kTBhS40"\
"MRsliKhrXQwGiahLXbgxE8XgI5Kg+MBX/P6hfjlUOt1dXT3dt6rPgT/31u2qO7e+"\
"+vvcW/3Kpk0ZSSAJJIEkkASSQBJIAklgIIFzaJUyBhA4b0Bb26Zz23aQx59JwA7e"\
"zEO3o0vDLhtxEUP3i1W1e7dx2t+hQ+j6gECPe5/QnNWmBAzxMg48hU6jH9GzaAk5"\
"0t0mMWFp0Fs5/gQSaOtT6ivoYqRQmvH+6w35z/gEDE6O/gkJ8t/o36r+D6XSyR3I"\
"oWOc292W5QgCg0ALroC7VF35+0W0EzkEO4GbxohyGGgBlrPlcNWlz9FjaAtyJHCT"\
"GFKOAm3AcrfTicC/j/bU+nVftebcFAHDiTk6pgyDdhndfZLjD6Jr1VEVcrf7dFuW"\
"Acq4oAVcFyJejGNs70WXI4eWg4KeURGw+5qAtrsjbLUdRvegS6q+VeT6u4LRBrTg"\
"Km9H4Np+A92AHOluSLQFbXcLsCdLtR1H+9AycvhveXuhSp/8JKnDkGMp2NHhR9h+"\
"EMW7y4XM3dMGbeiCbeB/Un8b3Ykcgr1QwDcKtIHH5eAPwNXd5ZJpV+VCAN9o0AKu"\
"dBKBf8H2I+gi5NA4eg18FqAHuVvpZBXdhWL0djk4S9CD3P0LlF9B8cUqjcnjiheh"\
"03Wf0LRWHXbvqFITZVwOrrH9BLoSOXrl7nmB9oXwysTbH0P5PnRhRVt522OsmrpZ"\
"+CRm7WiDVSlnR3crfx9ANyNH5+8uSwBt6IIdHf4128+gq5BD4+3k6qQk0BF4XA4q"\
"nTyM4nJQsDsFvETQBh4nTKWTd9FtKIbHH9uKrHug88zRBnu2Mrr7eyjq7nJHoCln"\
"+zxCc1lVD7Bk0LoAcnfM31+y/SSqf7Kq2HTSFdB2e3S3Jk+9d7kbnY8cRa6/uwZa"\
"wOurk99oewldbdKUxS0Huwja7hZwydtHqT+FtiNHMe7uMmi7uw58Fcr3owsq2kVM"\
"ll0HbTdH6Kr/jg6gWyrYKnSuc5ss+wTa0OOEuQbc59Aycgj2zIH3EbTdHYF/BtwV"\
"FFcnbM4u+gra7o5r7z/A+h66scI7U1f3HfQgd/8M6JfRFU2AG1R1TBalEvCFKv0W"\
"3KmgaRnzdKYOXNgU4Kj9tbaOkFtPhnObRQt9iuoCCLLuCKWv0JvoVbSGFJ4Ete/M"\
"ok+pI94hKk3sR15hCKjO1ZC1PdPoA+gIWC5dRboF97Nd5+jzpDqf8AC6OBnWAR8F"\
"Yb6oBAS5bRoS4Hgj8ivb+TLplOD6AsWVhIB/gHYjpwmq65OgyqKiK6mj7uJ8Kwsb"\
"2X3TKqOL9ebsC2hHsKtWEnNbTYRxDK2W7GjlYTlZF0wfN3gH3YpiePyxrci6B1rS"\
"qkNwo4s/YvshNNcP0MRJoMgr2WBQTjW6+Lqr+wa9hvZXdYr19bD303ZnogRHy8FO"\
"EU4TgntToCjwxefhMN4zqvMGHQEL8ofoXpQf2wWCn7ptyjjRqZ9j6HG0HTnk4t7E"\
"rB0tB8eJzu927AxENSaPKzR3u+oTmsWqQy72s0DLtVVU/7KQx8ND/Qqf2EaCrrtY"\
"P66SX38DQnSeHThpGdOEvtCpu7olFKPTq4l4IsPqG+VoXSxfML0I/xbaEwYiuAsB"\
"2Oc8bdBKEwasZ8ERtILicm2hAHPu6zEt0AIsOcUcp74PLSNHr5ZrPqlxy7ag6w7W"\
"auJ1lD+MUrsCbUDHFCEnH0Z3oy3hbyy0iwOH/28Mmizv4kQnwGtoL8ofrwLC2aKp"\
"o+Ny7SSdHkTXhM410bnP0JxVQxnlaLnYk91f1PMHBht6ZxRowY0u1l3doyjmYblY"\
"yhhCYBjoONl9Sx/Po/jiTwIeArb+0CDQcrDThGAfQrvCgTomHRyAjFM16K3sfAL5"\
"hkPlJ+gB5DQhuN6fakYTAganyfAUEmCliafREnLketgkJiwNehvH+z9TuC70pccz"\
"TQQgk1YNcTMd7EL1L7FP2m8eNwaBdPEYkNrsInfb4W36yWOTQBJIAkkgCSSBJJAE"\
"kkDpBP4DMYzU0Nx3BLMAAAAASUVORK5CYII="

UIImage *SKIVolumeImage(void) {
	static UIImage *image = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSData *data = [[NSData alloc] initWithBase64EncodedString:SKI_VOLUME_BASE64
														   options:0];
		
		image = [UIImage imageWithData:data];
	});
	
	return image;
}

UIImage *SKIMuteImage(void) {
	static UIImage *image = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSData *data = [[NSData alloc] initWithBase64EncodedString:SKI_MUTE_BASE64
														   options:0];
		
		image = [UIImage imageWithData:data];
	});
	
	return image;
}

UIImage *SKIPlayImage(void) {
	static UIImage *image = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSData *data = [[NSData alloc] initWithBase64EncodedString:SKI_PLAY_BASE64
														   options:0];
		
		image = [UIImage imageWithData:data];
	});
	
	return image;
}

UIImage *SKIPauseImage(void) {
	static UIImage *image = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSData *data = [[NSData alloc] initWithBase64EncodedString:SKI_PAUSE_BASE64
														   options:0];
		
		image = [UIImage imageWithData:data];
	});
	
	return image;
}

UIImage *SKIMuteImageWithSize(CGSize size) {
	UIImage *originalImage = SKIMuteImage();
	if (CGSizeEqualToSize(originalImage.size, size)) {
		return originalImage;
	}
	
	UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
	
	[originalImage drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return image;
}

UIImage *SKIVolumeImageWithSize(CGSize size) {
	UIImage *originalImage = SKIVolumeImage();
	if (CGSizeEqualToSize(originalImage.size, size)) {
		return originalImage;
	}
	
	UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
	
	[originalImage drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return image;
}

UIImage *SKIPlayImageWithSize(CGSize size) {
	UIImage *originalImage = SKIPlayImage();
	if (CGSizeEqualToSize(originalImage.size, size)) {
		return originalImage;
	}
	
	UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
	
	[originalImage drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return image;
}

UIImage *SKIPauseImageWithSize(CGSize size) {
	UIImage *originalImage = SKIPauseImage();
	if (CGSizeEqualToSize(originalImage.size, size)) {
		return originalImage;
	}
	
	UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
	
	[originalImage drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return image;
}

