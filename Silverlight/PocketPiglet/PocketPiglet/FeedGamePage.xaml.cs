using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Shapes;
using Microsoft.Phone.Controls;
using System.Windows.Navigation;
using Microsoft.Xna.Framework.Audio;
using System.Windows.Media.Imaging;
using System.IO.IsolatedStorage;
using System.Windows.Threading;

namespace PocketPiglet
{
    public partial class FeedGamePage : PhoneApplicationPage
    {
        private string typeLevel;
        private int countShelf;
        private int widthItem;
        private int heightItem;
        private Image foodImage;
        private Image sandwichImage;
        private List<Food> listItem;
        private List<Food> listItemGame;
        private List<Image> listSandwichItem;
        private int[,] arrShiftEasy;
        private int[,] arrShiftMedium;
        private int[,] arrShiftHard;
        private int maxLevel;
        private int currentLevel;
        private int countTypeFood;
        private Random rnd;
        private int currentFood;
        private bool loadOnLayoutUpdate;
        private int currentItemDrop;
        private int ySandwich;
        private string animationPigletPlay;
        private DispatcherTimer timerStartLevel;
        private DispatcherTimer timerPigletEat;
        private int countTickPigletEat;
        private int currentBackground = 1;
        private bool isFoodImageActive = false;
        private int countItemOpacity;
        private int currentCountItemOpacity;
        private string lastGamePiglet;
        private bool isPlayAnimationDropBread;


        public struct Food
        {
            public int index;
            public string source;
            public string source_sandwich;
            public Food(int i, string src, string sndwch)
            {
                index = i;
                source = src;
                source_sandwich = sndwch;
            }
        }

        public FeedGamePage()
        {
            InitializeComponent();
            this.timerPigletEat = new System.Windows.Threading.DispatcherTimer();
            this.timerPigletEat.Tick += new EventHandler(timerPigletEat_Tick);
            this.timerPigletEat.Interval = new TimeSpan(0, 0, 0, 0, 200);

            this.timerStartLevel = new System.Windows.Threading.DispatcherTimer();
            this.timerStartLevel.Tick += new EventHandler(timerStartLevel_Tick);
            this.timerStartLevel.Interval = new TimeSpan(0, 0, 0, 3, 0);

            this.isPlayAnimationDropBread = false;
            this.loadOnLayoutUpdate = true;
            IsolatedStorageSettings.ApplicationSettings.TryGetValue<string>("AnimationPigletPlay", out this.animationPigletPlay);
            IsolatedStorageSettings.ApplicationSettings.TryGetValue<string>("LastGamePiglet", out this.lastGamePiglet);
            IsolatedStorageSettings.ApplicationSettings["LastGamePiglet"] = "feed";
            IsolatedStorageSettings.ApplicationSettings["FeedGameState"] = true;
            IsolatedStorageSettings.ApplicationSettings.Save();
        }

        private void FeedGamePage_fihhArrShift()
        {
            this.arrShiftEasy[0, 0] = 45;
            this.arrShiftEasy[0, 1] = 35;
            this.arrShiftEasy[1, 0] = 20;
            this.arrShiftEasy[1, 1] = 20;

            this.arrShiftMedium[0, 0] = 30;
            this.arrShiftMedium[0, 1] = 20;
            this.arrShiftMedium[1, 0] = 15;
            this.arrShiftMedium[1, 1] = 15;
            this.arrShiftMedium[2, 0] = 5;
            this.arrShiftMedium[2, 1] = 5;


            this.arrShiftHard[0, 0] = 20;
            this.arrShiftHard[0, 1] = 15;
            this.arrShiftHard[1, 0] = 5;
            this.arrShiftHard[1, 1] = 0;
            this.arrShiftHard[2, 0] = -10;
            this.arrShiftHard[2, 1] = -10;
            this.arrShiftHard[3, 0] = -10;
            this.arrShiftHard[3, 1] = -5;


        }

        protected override void OnNavigatedTo(NavigationEventArgs e)
        {
            base.OnNavigatedTo(e);
            if (NavigationContext.QueryString.ContainsKey("typeLevel"))
            {
                this.typeLevel = NavigationContext.QueryString["typeLevel"].ToString();
            }
            this.loadOnLayoutUpdate = false;
        }

        protected override void OnNavigatingFrom(NavigatingCancelEventArgs e)
        {
            base.OnNavigatingFrom(e);
            IsolatedStorageSettings.ApplicationSettings["AnimationPigletPlay"] = "FeedPigletAnimation";
            IsolatedStorageSettings.ApplicationSettings.Save();
        }

        private void FeedGamePage_loadGame()
        {
            int[,] arrShift;
            this.currentFood = -1;
            this.rnd = new Random();
            this.listItem = new List<Food>();
            this.listSandwichItem = new List<Image>();
            this.listItemGame = new List<Food>();
            this.widthItem = 153;
            this.arrShiftEasy = new int[2, 2];
            this.arrShiftMedium = new int[3, 2];
            this.arrShiftHard = new int[4, 2];
            this.FeedGamePage_fihhArrShift();
            if (this.typeLevel == "easy")
            {
                this.countShelf = 2;
                this.heightItem = 180;
                this.ImageRefrigerator.Source = new BitmapImage(new Uri("/Images/piglet_feed/refrigerator_easy.png", UriKind.Relative));
                this.maxLevel = 3;
                arrShift = this.arrShiftEasy;
            }
            else if (this.typeLevel == "medium")
            {
                this.countShelf = 3;
                this.heightItem = 120;
                this.ImageRefrigerator.Source = new BitmapImage(new Uri("/Images/piglet_feed/refrigerator_medium.png", UriKind.Relative));
                arrShift = this.arrShiftMedium;
                this.maxLevel = 5;
            }
            else
            {
                this.countShelf = 4;
                this.heightItem = 90;
                this.ImageRefrigerator.Source = new BitmapImage(new Uri("/Images/piglet_feed/refrigerator_hard.png", UriKind.Relative));
                arrShift = this.arrShiftHard;
                this.maxLevel = 8;
            }

            for (int i = 0; i < this.countShelf; i++)
            {
                RowDefinition r = new RowDefinition();
                r.Height = new GridLength(this.heightItem);
                GridPuzzle.RowDefinitions.Add(r);
            }
            for (int i = 0; i < 2; i++)
            {
                ColumnDefinition c = new ColumnDefinition();
                c.Width = new GridLength(this.widthItem);
                GridPuzzle.ColumnDefinitions.Add(c);
            }
            Food foodItem;
            foodItem = new Food(0, "/Images/piglet_feed/food_cheese.png", "/Images/piglet_feed/sandwich_cheese.png");
            listItem.Add(foodItem);
            foodItem = new Food(1, "/Images/piglet_feed/food_cucumber.png", "/Images/piglet_feed/sandwich_cucumber.png");
            listItem.Add(foodItem);
            foodItem = new Food(2, "/Images/piglet_feed/food_fish.png", "/Images/piglet_feed/sandwich_fish.png");
            listItem.Add(foodItem);
            foodItem = new Food(3, "/Images/piglet_feed/food_ketchup.png", "/Images/piglet_feed/sandwich_ketchup.png");
            listItem.Add(foodItem);
            foodItem = new Food(4, "/Images/piglet_feed/food_mayonnaise.png", "/Images/piglet_feed/sandwich_mayonnaise.png");
            listItem.Add(foodItem);
            foodItem = new Food(5, "/Images/piglet_feed/food_olives.png", "/Images/piglet_feed/sandwich_olives.png");
            listItem.Add(foodItem);
            foodItem = new Food(6, "/Images/piglet_feed/food_salad.png", "/Images/piglet_feed/sandwich_salad.png");
            listItem.Add(foodItem);
            foodItem = new Food(7, "/Images/piglet_feed/food_tomato.png", "/Images/piglet_feed/sandwich_tomato.png");
            listItem.Add(foodItem);

            int indexImage = 0;
            for (int i = 0; i < this.countShelf; i++)
            {
                for (int j = 0; j < 2; j++)
                {
                    this.foodImage = new Image();
                    this.foodImage.Width = 128;
                    this.foodImage.Height = 72;
                    this.foodImage.RenderTransform = new TranslateTransform() { X = 0, Y = arrShift[i, j] };
                    this.foodImage.Tag = Convert.ToString(indexImage);
                    this.foodImage.Source = new BitmapImage(new Uri(listItem[indexImage].source, UriKind.Relative));
                    this.foodImage.MouseLeftButtonDown += new MouseButtonEventHandler(foodImage_MouseLeftButtonDown);
                    Canvas.SetZIndex(this.foodImage, 3);
                    Grid.SetColumn(this.foodImage, j);
                    Grid.SetRow(this.foodImage, i);
                    this.GridPuzzle.Children.Add(this.foodImage);

                    indexImage++;
                }
            }
            this.currentFood = -1;
            this.countTypeFood = this.countShelf * 2;
            this.currentLevel = 1;

        }

        private void foodImage_MouseLeftButtonDown(object sender, MouseButtonEventArgs e)
        {
            if (!this.isFoodImageActive) return;
            Image item = sender as Image;            
            if (Convert.ToString(item.Tag) == Convert.ToString(this.listItemGame[this.currentItemDrop].index))
            {
                this.sandwichImage = new Image();
                this.sandwichImage.Width = 80;
                this.sandwichImage.Height = 36;
                this.sandwichImage.Tag = "sandwich";
                int x = 490;
                int y = 0;
                this.sandwichImage.Margin = new Thickness(x, y, this.GameGrid.ActualWidth - x - this.sandwichImage.Width, this.GameGrid.ActualHeight - y - this.sandwichImage.Height);
                this.sandwichImage.RenderTransform = new TranslateTransform() { X = 0, Y = 0 };
                this.sandwichImage.Source = new BitmapImage(new Uri(this.listItemGame[this.currentItemDrop].source_sandwich, UriKind.Relative));
                Canvas.SetZIndex(this.sandwichImage, 6);
                this.GameGrid.Children.Add(this.sandwichImage);
                this.listSandwichItem.Add(this.sandwichImage);

                this.ySandwich -= 5;
                Storyboard sbSandwichItem = new Storyboard();
                DoubleAnimation animationSandwichItem = new DoubleAnimation();
                animationSandwichItem.From = 0;
                animationSandwichItem.To = this.ySandwich;
                animationSandwichItem.Duration = new Duration(TimeSpan.FromSeconds(0.4));
                Storyboard.SetTarget(animationSandwichItem, this.sandwichImage);
                Storyboard.SetTargetProperty(animationSandwichItem, new PropertyPath("(UIElement.RenderTransform).(TranslateTransform.Y)"));
                sbSandwichItem.Completed += new EventHandler(storyCompletedImageDrop);
                sbSandwichItem.Children.Add(animationSandwichItem);
                sbSandwichItem.Begin();
                this.currentItemDrop++;
                if (this.listItemGame.Count == this.currentItemDrop) this.isFoodImageActive = false;
            }
            else
            {
                var laserStream = Application.GetResourceStream(new Uri("Sound/piglet_feed/game_over.wav", UriKind.RelativeOrAbsolute));
                var effect = SoundEffect.FromStream(laserStream.Stream);
                effect.Play();
                MessageBoxResult result = MessageBox.Show(AppResources.MessageBoxMessageGameOverQuestion, AppResources.MessageBoxHeaderInfo, MessageBoxButton.OKCancel);
                if (result == MessageBoxResult.OK)
                {
                    this.FeedGamePage_StopGame();
                    this.FeedGamePage_gamePlay();
                }
                else
                {
                    this.FeedGamePage_StopGame();
                    NavigationService.GoBack();
                }
            }
            item.CaptureMouse();
        }

        private void storyCompletedImageDrop(object sender, EventArgs e)
        {
            if (this.listItemGame.Count == this.currentItemDrop && this.isPlayAnimationDropBread)
            {
                this.isPlayAnimationDropBread = false;
                this.sandwichImage = new Image();
                this.sandwichImage.Width = 80;
                this.sandwichImage.Height = 36;
                int x = 490;
                int y = 0;
                this.ySandwich -= 5;
                this.sandwichImage.Margin = new Thickness(x, y, this.GameGrid.ActualWidth - x - this.sandwichImage.Width, this.GameGrid.ActualHeight - y - this.sandwichImage.Height);
                this.sandwichImage.Tag = "sandwich";
                this.sandwichImage.RenderTransform = new TranslateTransform() { X = 0, Y = 0 };
                this.sandwichImage.Source = new BitmapImage(new Uri("/Images/piglet_feed/sandwich_bread_top.png", UriKind.Relative));
                Canvas.SetZIndex(this.sandwichImage, 6);
                this.GameGrid.Children.Add(this.sandwichImage);
                this.listSandwichItem.Add(this.sandwichImage);
                Storyboard sbSandwichItem = new Storyboard();
                DoubleAnimation animationSandwichItem = new DoubleAnimation();
                animationSandwichItem.From = 0;
                animationSandwichItem.To = this.ySandwich;
                animationSandwichItem.Duration = new Duration(TimeSpan.FromSeconds(0.4));
                Storyboard.SetTarget(animationSandwichItem, this.sandwichImage);
                Storyboard.SetTargetProperty(animationSandwichItem, new PropertyPath("(UIElement.RenderTransform).(TranslateTransform.Y)"));
                sbSandwichItem.Completed += new EventHandler(storyCompletedBreadTop);
                sbSandwichItem.Children.Add(animationSandwichItem);
                sbSandwichItem.Begin();
            }
        }

        private void storyCompletedBreadTop(object sender, EventArgs e)
        {

            this.countTickPigletEat = 0;
            this.currentBackground = 1;
            this.timerPigletEat.Start();
            var laserStream = Application.GetResourceStream(new Uri("Sound/piglet_feed/sandwich_eat.wav", UriKind.RelativeOrAbsolute));
            var effect = SoundEffect.FromStream(laserStream.Stream);
            effect.Play();
        }

        private void timerPigletEat_Tick(object sender, EventArgs e)
        {
            this.timerPigletEat.Stop();
            string bg1 = "/Images/piglet_feed/background.png";
            string bg2 = "/Images/piglet_feed/background_eat.png";
            if (this.currentBackground == 1)
            {
                this.ImageBackground.Source = new BitmapImage(new Uri(bg2, UriKind.Relative));
                this.currentBackground = 2;
            }
            else
            {
                this.ImageBackground.Source = new BitmapImage(new Uri(bg1, UriKind.Relative));
                this.currentBackground = 1;
            }
            if (this.countTickPigletEat == 5)
            {
                if (this.currentLevel == this.maxLevel)
                {
                    var laserStream = Application.GetResourceStream(new Uri("Sound/piglet_feed/game_complete.wav", UriKind.RelativeOrAbsolute));
                    var effect = SoundEffect.FromStream(laserStream.Stream);
                    effect.Play();
                    MessageBoxResult result = MessageBox.Show(AppResources.MessageBoxMessageGameWonQuestion, AppResources.MessageBoxHeaderInfo, MessageBoxButton.OKCancel);
                    if (result == MessageBoxResult.OK)
                    {
                        this.FeedGamePage_StopGame();
                        this.FeedGamePage_gamePlay();
                    }
                    else
                    {
                        this.FeedGamePage_StopGame();
                        NavigationService.GoBack();
                    }
                }
                else
                {
                    this.currentLevel++;
                    this.FeedGamePage_ClearSandwichGame();
                    this.FeedGamePage_gamePlay();
                }
            }
            else
            {
                this.countTickPigletEat++;
                this.timerPigletEat.Start();
            }
        }

        private void FeedGamePage_ClearSandwichGame()
        {
            var images = this.GameGrid.Children.OfType<Image>();
            List<Image> ImagesListSandwich = new List<Image>();
            foreach (var img in images)
            {
                if (Convert.ToString(img.Tag) == (Convert.ToString("sandwich")))
                {
                    ImagesListSandwich.Add(img);
                }
            }
            foreach (var img_delete in ImagesListSandwich)
            {
                this.GameGrid.Children.Remove(img_delete);
            }
        }

        private void FeedGamePage_StopGame()
        {
            this.currentLevel = 1;
            this.FeedGamePage_ClearSandwichGame();
            this.listItemGame.Clear();
        }

        private void storyCompletedBreadBottom(object sender, EventArgs e)
        {
            Food currentFoodGame;
            List<int> tmlFoodList = new List<int>();
            int countFoodPlay;
            this.isFoodImageActive = false;
            if (this.currentLevel == 1)
            {
                countFoodPlay = 3;
            }
            else
            {
                countFoodPlay = 1;
            }
            for (int i = 1; i <= countFoodPlay; i++)
            {
                if (this.currentFood == -1)
                {
                    this.currentFood = this.rnd.Next(0, this.countTypeFood);
                    currentFoodGame = listItem[this.currentFood];
                    this.listItemGame.Add(currentFoodGame);
                }
                else
                {
                    tmlFoodList.Clear();
                    for (int fooAavailable = 0; fooAavailable < this.countTypeFood; fooAavailable++)
                    {
                        if (fooAavailable != this.currentFood)
                        {
                            tmlFoodList.Add(fooAavailable);
                        }
                    }
                    this.currentFood = tmlFoodList[this.rnd.Next(0, tmlFoodList.Count)];
                    currentFoodGame = listItem[this.currentFood];
                    this.listItemGame.Add(currentFoodGame);
                }
            }

            int mls = 0;
            this.countItemOpacity = listItemGame.Count;
            this.currentCountItemOpacity = 0;
            foreach (Food itemGame in listItemGame)
            {
                var images = this.GridPuzzle.Children.OfType<Image>();
                foreach (var img in images)
                {
                    if (Convert.ToString(img.Tag) == Convert.ToString(itemGame.index))
                    {
                        Storyboard sb = new Storyboard();
                        DoubleAnimation fadeInAnimation1 = new DoubleAnimation();
                        fadeInAnimation1.From = 1.0;
                        fadeInAnimation1.To = 0.0;
                        fadeInAnimation1.BeginTime = new TimeSpan(0, 0, 0, 0, mls);
                        fadeInAnimation1.Duration = new Duration(TimeSpan.FromSeconds(1.0));
                        Storyboard.SetTarget(fadeInAnimation1, img);
                        mls += 2000;
                        Storyboard.SetTargetProperty(fadeInAnimation1, new PropertyPath("(UIElement.Opacity)"));
                        fadeInAnimation1.AutoReverse = true;
                        sb.Completed += new EventHandler(storyCompletedItemOpacity);
                        sb.Children.Add(fadeInAnimation1);
                        sb.Begin();
                        break;
                    }

                }
            }
            this.currentItemDrop = 0;
            this.isPlayAnimationDropBread = true;
        }

        private void storyCompletedItemOpacity(object sender, EventArgs e)
        {
            this.currentCountItemOpacity++;
            if (this.currentCountItemOpacity == this.countItemOpacity)
            {
                this.isFoodImageActive = true;
            }
        }

        private void timerStartLevel_Tick(object sender, EventArgs e)
        {
            this.timerStartLevel.Stop();
            this.ImageBackgroundLevel.Visibility = Visibility.Collapsed;
            this.textBlockLevel.Visibility = Visibility.Collapsed;
            this.sandwichImage = new Image();
            this.sandwichImage.Width = 80;
            this.sandwichImage.Height = 36;
            int x = 490;
            int y = 0;
            this.ySandwich = 330;
            this.sandwichImage.Margin = new Thickness(x, y, this.GameGrid.ActualWidth - x - this.sandwichImage.Width, this.GameGrid.ActualHeight - y - this.sandwichImage.Height);
            this.sandwichImage.Tag = "sandwich";
            this.sandwichImage.RenderTransform = new TranslateTransform() { X = 0, Y = 0 };
            this.sandwichImage.Source = new BitmapImage(new Uri("/Images/piglet_feed/sandwich_bread_bottom.png", UriKind.Relative));
            Canvas.SetZIndex(this.sandwichImage, 6);
            this.GameGrid.Children.Add(this.sandwichImage);
            this.listSandwichItem.Add(this.sandwichImage);
            Storyboard sbSandwichItem = new Storyboard();
            DoubleAnimation animationSandwichItem = new DoubleAnimation();
            animationSandwichItem.From = 0;
            animationSandwichItem.To = this.ySandwich;
            animationSandwichItem.Duration = new Duration(TimeSpan.FromSeconds(0.4));
            Storyboard.SetTarget(animationSandwichItem, this.sandwichImage);
            Storyboard.SetTargetProperty(animationSandwichItem, new PropertyPath("(UIElement.RenderTransform).(TranslateTransform.Y)"));
            sbSandwichItem.Completed += new EventHandler(storyCompletedBreadBottom);
            sbSandwichItem.Children.Add(animationSandwichItem);
            sbSandwichItem.Begin();
        }

        private void FeedGamePage_gamePlay()
        {
            this.textBlockLevel.Text = String.Format(AppResources.FeedGamePageTextBlockLevelTextLevelNum, this.currentLevel, this.maxLevel) + Environment.NewLine + AppResources.FeedGamePageTextBlockLevelTextHint;
            this.ImageBackgroundLevel.Visibility = Visibility.Visible;
            this.textBlockLevel.Visibility = Visibility.Visible;
            var laserStream = Application.GetResourceStream(new Uri("Sound/piglet_feed/new_level.wav", UriKind.RelativeOrAbsolute));
            var effect = SoundEffect.FromStream(laserStream.Stream);
            effect.Play();
            this.timerStartLevel.Start();
        }

        private void GameGrid_LayoutUpdated(object sender, EventArgs e)
        {
        }

        private void FeedGamePage_LayoutUpdated(object sender, EventArgs e)
        {
            if (!this.loadOnLayoutUpdate)
            {
                this.loadOnLayoutUpdate = true;
                this.FeedGamePage_loadGame();
                this.FeedGamePage_gamePlay();
            }
        }
    }
}