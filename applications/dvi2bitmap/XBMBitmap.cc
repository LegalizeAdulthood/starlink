// $Id$

#include "Bitmap.h"
#include "XBMBitmap.h"
#include <cstdio>
#include <cctype>

XBMBitmap::XBMBitmap (const int w, const int h)
    : w_(w), h_(h), bitmapRows_(0), myBitmap_(false)
{
}

XBMBitmap::~XBMBitmap ()
{
    if (myBitmap_)
	delete[] allocBitmap_;
}

void XBMBitmap::setBitmap (const Byte *b)
{
    if (bitmapRows_ != 0)
	throw DviBug ("setBitmap: bitmap not empty");
    bitmap_ = b;
    bitmapRows_ = h_;
}

void XBMBitmap::setBitmapRow (const Byte *b)
{
    if (bitmapRows_ == 0)
    {
	allocBitmap_ = new Byte[w_ * h_];
	bitmap_ = allocBitmap_;
	myBitmap_ = true;
    }
    if (bitmapRows_ == h_)
	throw DviBug ("too many rows received by XBMBitmap::setBitmapRow");
    Byte *p = &allocBitmap_[bitmapRows_ * w_];
    for (int i=0; i<w_; i++)
	*p++ = *b++;
    bitmapRows_ ++;
}

void XBMBitmap::write (const string filename)
{
    FILE *op;
    if ((op = fopen (filename.c_str(), "w")) == NULL)
	throw BitmapError ("can't open XBM file"+filename+" to write");
    int dotpos = filename.find_last_of('.');
    int seppos = filename.find_last_of(path_separator);
    if (seppos < 0) seppos = 0;
    if (dotpos < 0) dotpos = filename.length();
    cerr << "seppos="<<seppos<<" dotpos="<<dotpos<<'\n';
    string fnroot_str = "";
    for (int charno=seppos; charno<dotpos; charno++)
	fnroot_str += (isalnum(filename[charno]) ? filename[charno] : '_');
    const char *fnroot = fnroot_str.c_str();

    fprintf (op, "#define %s_width %d\n", fnroot, w_);
    fprintf (op, "#define %s_height %d\n", fnroot, h_);
    fprintf (op, "static unsigned char %s_bits[] = {\n", fnroot);
    for (int row=0; row<h_; row++)
    {
	Byte b = 0;
	Byte bitno = 0;
	const Byte *p = &bitmap_[row*w_];
	for (int col=0; col<w_; col++)
	{
	    if (*p++)
		b |= (1<<bitno);
	    if (bitno == 7)
	    {
		fprintf (op, "0x%02x, ", b);
		b = 0;
		bitno = 0;
	    }
	    else
		bitno++;
	}
	if (bitno != 0)
	    fprintf (op, "0x%02x, ", static_cast<unsigned int>(b));
	fprintf (op, "\n");
    }
    fprintf (op, "};\n");
    fclose (op);
}
