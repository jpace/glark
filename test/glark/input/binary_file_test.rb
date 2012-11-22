#!/usr/bin/ruby -w
# -*- ruby -*-

require 'glark/app/tc'

class Glark::BinaryFileTestCase < Glark::AppTestCase
  def test_match
    fname = '/proj/org/incava/glark/test/resources/textfile.txt.gz'
    expected = [ "Binary file " + fname + " matches" ]
    run_app_test expected, [ '--binary=binary', 'i' ], fname
  end

  def test_no_match
    fname = '/proj/org/incava/glark/test/resources/textfile.txt.gz'
    expected = [ ]
    run_app_test expected, [ '--binary=binary', 'Q' ], fname
  end

  def test_as_text
    fname = '/proj/org/incava/glark/test/resources/textfile.txt.gz'
    expected = [ 
                '    1 ��$�P textf[30m[43mi[0mle.txt ���n�0E��',
                '    3 ��!��8�&qm��.���(�BIM?��n�A@���8w�X�ޫT-c��`[w�3���� +.�/(�ձs���4�������y#	,�����[30m[43mi[0m<ھ�Ť��,\X[��.�Р�K,����r�(�*%�&Ɨb�h�UnІ��޾�j���^h?���N7v��G�5ɫ���m��2�B5�_��r����f��V�؀j�����֥��a���E���f��-S`(a/ӷ����J�,d�oc;��4JR�e��6=ư&�'
                ]
    run_app_test expected, [ '--binary-files=text', 'i' ], fname
  end

  def test_skip
    fname = '/proj/org/incava/glark/test/resources/textfile.txt.gz'
    expected = [ ]
    run_app_test expected, [ '--binary=skip', 'i' ], fname
  end

  def test_without_match
    fname = '/proj/org/incava/glark/test/resources/textfile.txt.gz'
    expected = [ ]
    run_app_test expected, [ '--binary=without-match', 'i' ], fname
  end

  def run_decompress_gz_single_test binopt
    fname = '/proj/org/incava/glark/test/resources/textfile.txt.gz'
    expected = [ 
                "    5   -rw-r--r--   1 jpace jpace    6525 2010-12-04 15:24 04-[30m[43mTheCooksTale.txt[0m",
                "   10   -rw-r--r--   1 jpace jpace   64791 2010-12-04 15:24 09-[30m[43mTheClerksTale.txt[0m",
                "   23   -rw-r--r--   1 jpace jpace   52953 2010-12-04 15:24 22-[30m[43mTheCanonsYeomansTale.txt[0m",
               ]
    run_app_test expected, [ '--binary=' + binopt, 'The.*C.*' ], fname
  end

  def run_decompress_gz_multiple_test binopt
    fnames = [ '/proj/org/incava/glark/test/resources/textfile.txt.gz',  '/proj/org/incava/glark/test/resources/zfile.txt.gz' ]
    expected = [ 
                "[1m/proj/org/incava/glark/test/resources/textfile.txt.gz[0m",
                "   18   -rw-r--r--   1 jpace jpace   14834 2010-12-04 15:24 17-Ch[30m[43maucersTaleOfSi[0mrThopas.txt",
                "   19   -rw-r--r--   1 jpace jpace   43249 2010-12-04 15:24 18-Ch[30m[43maucersTaleOfMeli[0mboeus.txt",
                "[1m/proj/org/incava/glark/test/resources/zfile.txt.gz[0m",
                "   16 zyg[30m[43maeni[0md",
               ]
    run_app_test expected, [ '--binary=' + binopt, 'a\w*e\w*i' ], *fnames
  end

  def test_decompress_gz_single
    run_decompress_gz_single_test 'decompress'
  end

  def test_decompress_gz_multiple
    run_decompress_gz_multiple_test 'decompress'
  end

  def test_read_gz_single
    run_decompress_gz_single_test 'read'
  end

  def test_read_gz_multiple
    run_decompress_gz_multiple_test 'read'
  end

  def test_list_tar_single
    fname = '/proj/org/incava/glark/test/resources/rc.tar'
    expected = [ 
                "    4 rcm[30m[43ma[0mtch.txt",
                "    5 rcp[30m[43ma[0mth.txt",
               ]
    run_app_test expected, [ '--binary=list', 'a' ], fname
  end

  def test_contents_tar_single
    fname = '/proj/org/incava/glark/test/resources/rc.tar'
    expected = [ 
                "[1mrcfile.txt (in /proj/org/incava/glark/test/resources/rc.tar)[0m",
                "    2 h[30m[43mighlight: si[0mngle",
                "    3 # h[30m[43mighlight: multi[0m",
                "    4 local-conf[30m[43mig-fi[0mles: true",
                "    8 s[30m[43mize-limi[0mt: 1000",
                "[1mrcpath.txt (in /proj/org/incava/glark/test/resources/rc.tar)[0m",
                "    1 match-d[30m[43mirpath: src/mai[0mn/java",
                "    4 not-d[30m[43mirpath: org/incava/uti[0ml",
               ]
    run_app_test expected, [ '--binary=read', 'i.*i' ], fname
  end

  def test_list_targz_single
    fname = '/proj/org/incava/glark/test/resources/rubies.tar.gz'
    expected = [ 
                "    2 [30m[43me[0mcho.rb",
                "    3 gr[30m[43me[0m[30m[43me[0mt.rb",
               ]
    run_app_test expected, [ '--binary=list', 'e' ], fname
  end

  def test_list_targz_multiple
    fnames = [ '/proj/org/incava/glark/test/resources/rubies.tar.gz', 'doesnotexist' ]
    expected = [ 
                "[1m/proj/org/incava/glark/test/resources/rubies.tar.gz[0m",
                "    2 [30m[43me[0mcho.rb",
                "    3 gr[30m[43me[0m[30m[43me[0mt.rb",
               ]
    run_app_test expected, [ '--binary=list', 'e' ], *fnames
  end

  def test_list_jar_single
    fname = '/proj/org/incava/glark/test/resources/org-incava-ijdk-1.0.1.jar'
    expected = [ 
                "   15 o[30m[43mrg/incava/ijdk/lang/BooleanArr[0may.class",
                "   26 o[30m[43mrg/incava/ijdk/lang/ByteArr[0may.class",
                "   33 o[30m[43mrg/incava/ijdk/lang/Integer[0mExt.class",
                "   41 o[30m[43mrg/incava/ijdk/lang/IntegerArr[0may.class",
                "   57 o[30m[43mrg/incava/ijdk/lang/DoubleArr[0may.class",
                "   65 o[30m[43mrg/incava/ijdk/lang/OrderedPair[0m.class",
                "   73 o[30m[43mrg/incava/ijdk/lang/Range$RangeIterator[0m.class",
               ]
    run_app_test expected, [ '--binary=list', 'r.*a.*n.*g.*e.*r' ], fname
  end

  def test_list_zip_single
    fname = '/proj/org/incava/glark/test/resources/aaa.zip'
    expected = [ 
                "    2 [30m[43madd[0m.rb",
               ]
    run_app_test expected, [ '--binary=list', 'a.*d' ], fname
  end

  def test_read_zip_single
    fname = '/proj/org/incava/glark/test/resources/aaa.zip'
    expected = [ 
                "[1mabcfile.txt (in /proj/org/incava/glark/test/resources/aaa.zip)[0m",
                "    1 A[30m[43mB[0mC",
                "    2 [30m[43mD[0mEF",
                "    3 [30m[43mG[0mHI",
                "    4 [30m[43mJ[0mKL",
                "[1madd.rb (in /proj/org/incava/glark/test/resources/aaa.zip)[0m",
                "   10 Adder.new AR[30m[43mG[0mV.shift || 2, AR[30m[43mG[0mV.shift || 2",
               ]
    run_app_test expected, [ '--binary=read', '[BDJG]' ], fname
  end
end
