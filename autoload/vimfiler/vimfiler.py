import os.path
import vim

class VimFiler(object):
    def getsize(self, path):
        try:
          filesize = os.path.getsize(path)
        except:
          filesize = -1

        if filesize < 0:
          pattern = ''
        else:
          mega = filesize / 1024 / 1024
          float = int((mega%1024)*100/1024)
          pattern = '%2d.%02d' % (mega/1024, float)
        return pattern

